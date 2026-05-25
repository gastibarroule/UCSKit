/// UCSKit — A standalone Swift library for parsing and searching
/// the Universal Category System (UCS v8.2.1) sound classification standard.
///
/// ## Overview
/// UCSKit provides three core components:
/// - ``UCSCategory``: The immutable data model
/// - ``UCSParser``: An actor-based, non-blocking CSV parser
/// - ``UCSSearchEngine``: A ranked search engine with NaturalLanguage support
///
/// ## Quick Start
/// ```swift
/// let parser = UCSParser(batchSize: 100)
/// let categories = try await parser.parse(fileAt: csvURL)
/// let results = UCSSearchEngine.search(query: "thunder", in: categories)
/// ```
public enum UCSKit {
    /// The UCS specification version this library targets.
    public static let specVersion = "8.2.1"
}
