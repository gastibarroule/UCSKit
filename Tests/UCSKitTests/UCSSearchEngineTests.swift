import XCTest
@testable import UCSKit

final class UCSSearchEngineTests: XCTestCase {
    let mockData = [
        UCSCategory(catID: "AMBUrbn", category: "AMBIENCE", subCategory: "URBAN", catShort: "AMB", explanation: "City sounds", synonyms: ["city", "street"]),
        UCSCategory(catID: "AIRBlow", category: "AIR", subCategory: "BLOW", catShort: "AIR", explanation: "Steady air blows", synonyms: ["wind", "puff"])
    ]
    
    func testEmptyQueryReturnsAll() {
        let results = UCSSearchEngine.search(query: "", in: mockData)
        XCTAssertEqual(results.count, 2)
    }
    
    func testExactCategoryMatch() {
        let results = UCSSearchEngine.search(query: "ambience", in: mockData)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].catID, "AMBUrbn")
    }
    
    func testSynonymMatch() {
        let results = UCSSearchEngine.search(query: "puff", in: mockData)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].catID, "AIRBlow")
    }
    
    func testUniqueCategories() {
        let cats = UCSSearchEngine.uniqueCategories(from: mockData)
        XCTAssertEqual(cats, ["AIR", "AMBIENCE"])
    }
}
