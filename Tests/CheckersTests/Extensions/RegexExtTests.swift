import Core
import XCTest

final class RegexExtTests: XCTestCase {
  func testReplacingMatchesInInputWithTemplate() throws {
    let regexTrailing: Regex = try .init(#"(?<=\n)([-–] .*[^ ])( {0,1}| {3,})\n"#)
    let text: String = "\n- Sample Text.\n"

    XCTAssertEqual(
      regexTrailing.replacingMatches(in: text, with: "$1  \n"),
      "\n- Sample Text.  \n"
    )
  }
}
