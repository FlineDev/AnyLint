@testable import Utility
import XCTest

final class RegexExtTests: XCTestCase {
    func testStringLiteralInit() {
        let regex: Regex = #".*"#
        XCTAssertEqual(regex.description, #"Regex<".*">"#)
    }
}
