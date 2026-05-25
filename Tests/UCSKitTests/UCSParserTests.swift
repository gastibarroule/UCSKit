import XCTest
@testable import UCSKit

final class MockPersistenceDelegate: UCSPersistenceDelegate, @unchecked Sendable {
    var batches: [[UCSCategory]] = []
    var finishedCount: Int? = nil
    var error: UCSParserError? = nil
    
    func didParseBatch(_ categories: [UCSCategory]) async throws {
        batches.append(categories)
    }
    
    func didFinishParsing(totalCount: Int) async {
        finishedCount = totalCount
    }
    
    func didEncounterError(_ error: UCSParserError) async {
        self.error = error
    }
}

final class UCSParserTests: XCTestCase {
    func testCSVParser() async throws {
        let csvString = """
        Category,SubCategory,CatID,CatShort,Explanations,Synonyms - Comma Separated
        AIR,BLOW,AIRBlow,AIR,"Steady air blows.","Aerosol, Air, Balloon"
        AIR,BURST,AIRBrst,AIR,"Sharp air releases, like a pop.","Airbed, Airblast, Burst"
        """
        
        let parser = UCSParser(batchSize: 1)
        let delegate = MockPersistenceDelegate()
        await parser.setDelegate(delegate)
        
        let results = try await parser.parse(csvContent: csvString)
        
        XCTAssertEqual(results.count, 2)
        
        XCTAssertEqual(results[0].catID, "AIRBlow")
        XCTAssertEqual(results[0].category, "AIR")
        XCTAssertEqual(results[0].explanation, "Steady air blows.")
        XCTAssertEqual(results[0].synonyms, ["Aerosol", "Air", "Balloon"])
        
        XCTAssertEqual(results[1].catID, "AIRBrst")
        XCTAssertEqual(results[1].explanation, "Sharp air releases, like a pop.")
        XCTAssertEqual(results[1].synonyms, ["Airbed", "Airblast", "Burst"])
        
        let finishedCount = delegate.finishedCount
        XCTAssertEqual(finishedCount, 2)
        
        let batches = delegate.batches
        XCTAssertEqual(batches.count, 2)
        XCTAssertEqual(batches[0][0].catID, "AIRBlow")
        XCTAssertEqual(batches[1][0].catID, "AIRBrst")
    }
}
