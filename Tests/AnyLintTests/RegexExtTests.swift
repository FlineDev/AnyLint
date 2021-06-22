@testable import AnyLint
@testable import Utility
import XCTest

final class RegexExtTests: XCTestCase {
  func testInitWithStringLiteral() {
    let regex: Regex = #"(?<name>capture[_\-\.]group)\s+\n(.*)"#
    XCTAssertEqual(regex.pattern, #"(?<name>capture[_\-\.]group)\s+\n(.*)"#)
  }

  func testInitWithDictionaryLiteral() {
    let regex: Regex = [
      "name": #"capture[_\-\.]group"#,
      "suffix": #"\s+\n.*"#,
    ]
    XCTAssertEqual(regex.pattern, #"(?<name>capture[_\-\.]group)(?<suffix>\s+\n.*)"#)
  }
}
