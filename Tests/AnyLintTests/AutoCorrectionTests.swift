@testable import AnyLint
import XCTest

final class AutoCorrectionTests: XCTestCase {
    func testInitWithDictionaryLiteral() {
        let autoCorrection: AutoCorrection = ["before": "Lisence", "after": "License"]
        XCTAssertEqual(autoCorrection.before, "Lisence")
        XCTAssertEqual(autoCorrection.after, "License")
    }
}
