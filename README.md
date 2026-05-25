# UCSKit

A high-performance, open-source Swift Package for parsing, indexing, and searching the **Universal Category System (UCS)** sound-effects classification standard.

Currently targets **UCS v8.2.1**.

## Features

- **Zero External Dependencies**: Built entirely with Foundation and NaturalLanguage.
- **Actor-based CSV Parser**: `UCSParser` uses Swift 6 strict concurrency to parse the official UCS CSV data in a non-blocking background thread.
- **Batch Processing**: Exposes a `UCSPersistenceDelegate` protocol to safely stream parsed data into your own database (Realm, CoreData, SwiftData, or in-memory caches).
- **Semantic Search Engine**: `UCSSearchEngine` features a multi-signal scoring algorithm with Apple NaturalLanguage (`NLEmbedding`) fallback for robust, typo-tolerant semantic search out-of-the-box.
- **Thread Safe**: Fully `Sendable` models and data structures.

## Installation

### Swift Package Manager

Add `UCSKit` to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/gastibarroule/UCSKit.git", from: "1.0.0")
]
```

Or add it directly via Xcode:
**File > Add Packages...** and paste the repository URL: `https://github.com/gastibarroule/UCSKit.git`

## Quick Start

### 1. Define a Persistence Delegate

Since UCSKit is database-agnostic, you need to tell it what to do with the parsed categories. 

```swift
import UCSKit

final class MyDatabaseBridge: UCSPersistenceDelegate, @unchecked Sendable {
    func didParseBatch(_ categories: [UCSCategory]) async throws {
        // Save batch to Realm / CoreData / Array
        print("Received batch of \(categories.count) categories")
    }
    
    func didFinishParsing(totalCount: Int) async {
        print("Successfully parsed \(totalCount) categories")
    }
    
    func didEncounterError(_ error: UCSParserError) async {
        print("Error: \(error)")
    }
}
```

### 2. Parse the UCS Data

Pass the included CSV file (or your own) to the parser.

```swift
let parser = UCSParser(batchSize: 100)
let bridge = MyDatabaseBridge()
await parser.setDelegate(bridge)

// Get the bundled CSV URL
if let csvURL = Bundle.module.url(forResource: "UCS_v8.2.1", withExtension: "csv") {
    let categories = try await parser.parse(fileAt: csvURL)
}
```

### 3. Search the Database

Use the built-in search engine to query your categories. The search engine automatically weighs exact matches, prefixes, synonyms, and semantic neighbors.

```swift
let results = UCSSearchEngine.search(query: "thunder", in: categories, maxResults: 10)

for result in results {
    print("[\(result.catID)] \(result.category) -> \(result.subCategory)")
}
```

## Requirements
- iOS 16.0+
- macOS 14.0+
- Swift 5.9+

## License
UCSKit is available under the MIT license. See the LICENSE file for more info. 
The Universal Category System (UCS) itself is a public-domain initiative.
