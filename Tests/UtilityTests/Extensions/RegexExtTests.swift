@testable import Utility
import XCTest

final class RegexExtTests: XCTestCase {
  func testStringLiteralInit() {
    let regex: Regex = #".*"#
    XCTAssertEqual(regex.description, #"/.*/"#)
  }

  func testStringLiteralInitWithOptions() {
    let regexI: Regex = #".*\i"#
    XCTAssertEqual(regexI.description, #"/.*/i"#)

    let regexM: Regex = #".*\m"#
    XCTAssertEqual(regexM.description, #"/.*/m"#)

    let regexIM: Regex = #".*\im"#
    XCTAssertEqual(regexIM.description, #"/.*/im"#)

    let regexMI: Regex = #".*\mi"#
    XCTAssertEqual(regexMI.description, #"/.*/im"#)
  }

  func testDictionaryLiteralInit() {
    let regex: Regex = ["chars": #"[a-z]+"#, "num": #"\d+\.?\d*"#]
    XCTAssertEqual(regex.description, #"/(?<chars>[a-z]+)(?<num>\d+\.?\d*)/"#)
  }

  func testDictionaryLiteralInitWithOptions() {
    let regexI: Regex = ["chars": #"[a-z]+"#, "num": #"\d+\.?\d*"#, #"\"#: "i"]
    XCTAssertEqual(regexI.description, #"/(?<chars>[a-z]+)(?<num>\d+\.?\d*)/i"#)

    let regexM: Regex = ["chars": #"[a-z]+"#, "num": #"\d+\.?\d*"#, #"\"#: "m"]
    XCTAssertEqual(regexM.description, #"/(?<chars>[a-z]+)(?<num>\d+\.?\d*)/m"#)

    let regexMI: Regex = ["chars": #"[a-z]+"#, "num": #"\d+\.?\d*"#, #"\"#: "mi"]
    XCTAssertEqual(regexMI.description, #"/(?<chars>[a-z]+)(?<num>\d+\.?\d*)/im"#)

    let regexIM: Regex = ["chars": #"[a-z]+"#, "num": #"\d+\.?\d*"#, #"\"#: "im"]
    XCTAssertEqual(regexIM.description, #"/(?<chars>[a-z]+)(?<num>\d+\.?\d*)/im"#)
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
