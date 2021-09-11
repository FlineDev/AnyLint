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

  func testReplaceAllCaptures() throws {
    let anonymousRefsRegex = try Regex(#"(\w+)\.(\w+)\.(\w+)"#)
    XCTAssertEqual(
      anonymousRefsRegex.replaceAllCaptures(in: "prefix.content.suffix", with: "$3-$2-$1"),
      "suffix-content-prefix"
    )

    let namedRefsRegex = try Regex(#"(?<prefix>\w+)\.(?<content>\w+)\.(?<suffix>\w+)"#)
    XCTAssertEqual(
      namedRefsRegex.replaceAllCaptures(in: "prefix.content.suffix", with: "$suffix-$content-$prefix"),
      "suffix-content-prefix"
    )
  }
}
