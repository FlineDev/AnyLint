@testable import Utility
import XCTest

final class RegexExtTests: XCTestCase {
    func testStringLiteralInit() {
        let regex: Regex = #".*"#
        XCTAssertEqual(regex.description, #"/.*/"#)
    }

    func testReplacingMatchesInInputWithTemplate() {
        let regexTrailing: Regex = #"(?<=\n)([-–] .*[^ ])( {0,1}| {3,})\n"#
        let text: String = "\n- Sample Text.\n"

        XCTAssertEqual(
            regexTrailing.replacingMatches(in: text, with: "$1  \n"),
            "\n- Sample Text.  \n"
        )
    }
}
