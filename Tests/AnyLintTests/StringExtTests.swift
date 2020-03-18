@testable import AnyLint
import Rainbow
@testable import Utility
import XCTest

final class StringExtTests: XCTestCase {
    func testRemoveNewlinesBetweenCaptureGroups() {
        XCTAssertEqual(
            """
            A
            (?<b>B)
            (?<c>C)
            D
            """.removeNewlinesBetweenCaptureGroups(),
            "A\n(?<b>B)(?<c>C)\nD"
        )
    }
}
