@testable import AnyLint
@testable import Utility
import XCTest

final class ArrayExtTests: XCTestCase {
   func testContainsLineAtIndexesMatchingRegex() {
      let regex: Regex = #"foo:bar"#
      let lines: [String] = ["hello\n foo", "hello\n foo bar", "hello bar", "\nfoo:\nbar", "foo:bar", ":foo:bar"]
      
      XCTAssertFalse(lines.containsLine(at: [1, 2, 3], matchingRegex: regex))
      XCTAssertFalse(lines.containsLine(at: [-2, -1, 0], matchingRegex: regex))
      XCTAssertFalse(lines.containsLine(at: [-1, 2, 10], matchingRegex: regex))
      XCTAssertFalse(lines.containsLine(at: [3, 2], matchingRegex: regex))
      
      XCTAssertTrue(lines.containsLine(at: [-2, 3, 4], matchingRegex: regex))
      XCTAssertTrue(lines.containsLine(at: [5, 6, 7], matchingRegex: regex))
      XCTAssertTrue(lines.containsLine(at: [-2, 4, 10], matchingRegex: regex))
   }
}
