import Foundation
@preconcurrency import NaturalLanguage

/// A high-performance search engine for UCS category data.
///
/// Uses a multi-signal scoring algorithm combining exact matching,
/// prefix matching, and Apple NaturalLanguage word embeddings for
/// semantic search.
public struct UCSSearchEngine: Sendable {
    
    nonisolated(unsafe) private static let embedding = NLEmbedding.wordEmbedding(for: .english)
    
    // Weights for scoring
    private static let categoryWeight = 10.0
    private static let subCategoryWeight = 8.0
    private static let synonymWeight = 6.0
    private static let explanationWeight = 4.0
    private static let semanticWeight = 2.0
    
    /// Performs a ranked search over the given categories.
    public static func search(
        query: String,
        in categories: [UCSCategory],
        maxResults: Int = 50
    ) -> [UCSCategory] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespaces)
        guard !trimmedQuery.isEmpty else {
            return categories
        }
        
        let tokens = tokenize(trimmedQuery)
        let semanticNeighbors = findSemanticNeighbors(for: tokens)
        
        var scoredResults: [(category: UCSCategory, score: Double)] = []
        
        for item in categories {
            let score = calculateScore(
                item: item,
                tokens: tokens,
                semanticNeighbors: semanticNeighbors
            )
            
            if score > 0 {
                scoredResults.append((category: item, score: score))
            }
        }
        
        return scoredResults
            .sorted { $0.score > $1.score }
            .map { $0.category }
            .prefix(maxResults)
            .map { $0 }
    }
    
    /// Returns all unique top-level category names, sorted alphabetically.
    public static func uniqueCategories(from categories: [UCSCategory]) -> [String] {
        let uniqueSet = Set(categories.map { $0.category })
        return Array(uniqueSet).sorted()
    }
    
    /// Returns sorted subcategories for a given category.
    public static func subCategories(for category: String, in categories: [UCSCategory]) -> [String] {
        let subCats = categories
            .filter { $0.category == category && !$0.subCategory.isEmpty }
            .map { $0.subCategory }
        return Array(Set(subCats)).sorted()
    }
    
    /// Finds a single category by its CatID.
    public static func category(byCatID catID: String, in categories: [UCSCategory]) -> UCSCategory? {
        return categories.first(where: { $0.catID == catID })
    }
    
    // MARK: - Private Methods
    
    private static func tokenize(_ text: String) -> [String] {
        return text.lowercased()
            .components(separatedBy: .punctuationCharacters)
            .joined(separator: " ")
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
    }
    
    private static func findSemanticNeighbors(for tokens: [String]) -> [String] {
        guard let embedding = embedding else { return [] }
        var neighbors: Set<String> = []
        
        for token in tokens {
            embedding.enumerateNeighbors(for: token, maximumCount: 3) { neighbor, _ in
                neighbors.insert(neighbor.lowercased())
                return true
            }
        }
        
        return Array(neighbors)
    }
    
    private static func calculateScore(item: UCSCategory, tokens: [String], semanticNeighbors: [String]) -> Double {
        var score = 0.0
        
        let categoryLower = item.category.lowercased()
        let subCategoryLower = item.subCategory.lowercased()
        let explanationLower = item.explanation.lowercased()
        
        // 1. Exact/Prefix Token Matching
        for token in tokens {
            if categoryLower.contains(token) {
                if categoryLower == token { score += categoryWeight * 20.0 }
                else if categoryLower.hasPrefix(token) { score += categoryWeight * 5.0 }
                else { score += categoryWeight }
            }
            
            if subCategoryLower.contains(token) {
                if subCategoryLower == token { score += subCategoryWeight * 20.0 }
                else if subCategoryLower.hasPrefix(token) { score += subCategoryWeight * 5.0 }
                else { score += subCategoryWeight }
            }
            
            if explanationLower.contains(token) {
                score += explanationWeight
            }
            
            for synonym in item.synonyms {
                let synLower = synonym.lowercased()
                if synLower.contains(token) {
                    if synLower == token { score += synonymWeight * 5.0 }
                    else { score += synonymWeight }
                }
            }
        }
        
        // 2. Semantic Matching
        if score < categoryWeight {
            for neighbor in semanticNeighbors {
                if categoryLower.contains(neighbor) || subCategoryLower.contains(neighbor) {
                    score += semanticWeight
                }
                
                for synonym in item.synonyms {
                    if synonym.lowercased().contains(neighbor) {
                        score += semanticWeight
                    }
                }
            }
        }
        
        return score
    }
}
