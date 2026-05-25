import XCTest
@testable import UCSKit

final class UCSCategoryTests: XCTestCase {
    func testInitialization() {
        let category = UCSCategory(
            catID: "AMBUrbn",
            category: "AMBIENCE",
            subCategory: "URBAN",
            catShort: "AMB",
            explanation: "City sounds.",
            synonyms: ["city", "street"]
        )
        
        XCTAssertEqual(category.id, "AMBUrbn")
        XCTAssertEqual(category.catID, "AMBUrbn")
        XCTAssertEqual(category.category, "AMBIENCE")
        XCTAssertEqual(category.subCategory, "URBAN")
        XCTAssertEqual(category.catShort, "AMB")
        XCTAssertEqual(category.explanation, "City sounds.")
        XCTAssertEqual(category.synonyms, ["city", "street"])
    }
}
