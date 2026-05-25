import Foundation

/// A single entry in the Universal Category System (UCS v8.2.1).
///
/// Each entry represents a unique sound-effect classification with a
/// hierarchical `category → subCategory` structure, a compact `catID`
/// identifier, and associated synonyms for search.
public struct UCSCategory: Codable, Hashable, Identifiable, Sendable {
    /// The compact alphanumeric identifier (e.g. `"AMBUrbn"`).
    /// Used as the stable unique ID and filename prefix in UCS-compliant naming.
    public var id: String { catID }

    public let catID: String
    public let category: String
    public let subCategory: String
    public let catShort: String
    public let explanation: String
    public let synonyms: [String]
    
    public init(catID: String, category: String, subCategory: String, catShort: String, explanation: String, synonyms: [String]) {
        self.catID = catID
        self.category = category
        self.subCategory = subCategory
        self.catShort = catShort
        self.explanation = explanation
        self.synonyms = synonyms
    }
}
