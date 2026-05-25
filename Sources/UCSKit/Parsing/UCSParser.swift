import Foundation

/// A non-blocking, actor-based CSV parser for the Universal Category System data.
public actor UCSParser {
    /// The batch size for delegate callbacks.
    public let batchSize: Int

    /// Optional delegate to receive parsed batches.
    public weak var delegate: UCSPersistenceDelegate?

    public init(batchSize: Int = 100) {
        self.batchSize = batchSize
    }

    /// Sets the delegate for the parser.
    public func setDelegate(_ delegate: UCSPersistenceDelegate?) {
        self.delegate = delegate
    }

    /// Parse a UCS CSV file at the given URL.
    /// Returns all parsed categories AND streams batches to the delegate.
    public func parse(fileAt url: URL) async throws -> [UCSCategory] {
        guard FileManager.default.fileExists(atPath: url.path) else {
            let error = UCSParserError.fileNotFound(url)
            await delegate?.didEncounterError(error)
            throw error
        }
        
        let content: String
        do {
            content = try String(contentsOf: url, encoding: .utf8)
        } catch {
            let parserError = UCSParserError.encodingError
            await delegate?.didEncounterError(parserError)
            throw parserError
        }
        
        return try await parse(csvContent: content)
    }

    /// Parse raw CSV string content.
    public func parse(csvContent: String) async throws -> [UCSCategory] {
        var allCategories: [UCSCategory] = []
        var currentBatch: [UCSCategory] = []
        
        // Split by different possible line endings
        let rows = csvContent.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        var lineNumber = 0
        
        for row in rows {
            lineNumber += 1
            
            let columns = parseCSVLine(row)
            
            // Skip header rows or empty rows
            guard columns.count >= 6,
                  !columns[0].isEmpty,
                  columns[0] != "Category",
                  columns[0] != "UCS v8.2.1 Category List",
                  !columns[0].starts(with: "8.2.1 adds no new categories") else {
                continue
            }
            
            let category = columns[0]
            let subCategory = columns[1]
            let catID = columns[2]
            let catShort = columns[3]
            let explanation = columns[4]
            let synonyms = parseSynonyms(columns[5])
            
            let ucsCategory = UCSCategory(
                catID: catID,
                category: category,
                subCategory: subCategory,
                catShort: catShort,
                explanation: explanation,
                synonyms: synonyms
            )
            
            allCategories.append(ucsCategory)
            currentBatch.append(ucsCategory)
            
            if currentBatch.count >= batchSize {
                try await delegate?.didParseBatch(currentBatch)
                currentBatch.removeAll(keepingCapacity: true)
                // Yield to avoid blocking the actor for too long
                await Task.yield()
            }
        }
        
        if !currentBatch.isEmpty {
            try await delegate?.didParseBatch(currentBatch)
        }
        
        if allCategories.isEmpty {
            let error = UCSParserError.emptyData
            await delegate?.didEncounterError(error)
            throw error
        }
        
        await delegate?.didFinishParsing(totalCount: allCategories.count)
        
        return allCategories
    }
    
    /// Parses a single CSV line, handling quoted fields correctly
    private func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var currentField = ""
        var inQuotes = false
        var previousCharWasQuote = false
        
        for char in line {
            if char == "\"" {
                if inQuotes && previousCharWasQuote {
                    // Escaped quote
                    currentField.append("\"")
                    previousCharWasQuote = false
                } else {
                    inQuotes.toggle()
                    previousCharWasQuote = true
                }
            } else if char == "," {
                if inQuotes {
                    currentField.append(char)
                } else {
                    result.append(currentField.trimmingCharacters(in: .whitespaces))
                    currentField = ""
                }
                previousCharWasQuote = false
            } else {
                if char != "\r" {
                    currentField.append(char)
                }
                previousCharWasQuote = false
            }
        }
        
        // Append the last field
        result.append(currentField.trimmingCharacters(in: .whitespaces))
        
        return result
    }
    
    /// Parses the synonyms field into an array
    private func parseSynonyms(_ synonymsString: String) -> [String] {
        let delimiter: Character = synonymsString.contains(";") ? ";" : ","
        
        return synonymsString
            .split(separator: delimiter)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}
