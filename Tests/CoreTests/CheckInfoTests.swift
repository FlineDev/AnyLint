@testable import Core
import XCTest

final class CheckTests: XCTestCase {
  func testInit() {
    let check = Check(id: "SampleId", hint: "Some hint.", severity: .warning)
    XCTAssertEqual(check.id, "SampleId")
    XCTAssertEqual(check.hint, "Some hint.")
    XCTAssertEqual(check.severity, .warning)

    XCTAssertEqual(Check(id: "id", hint: "hint").severity, .error)
  }

  func testCodable() throws {
    let check = Check(id: "SampleId", hint: "Some hint.", severity: .warning)
    let encodedData = try JSONEncoder().encode(check)
    let encodedString = String(data: encodedData, encoding: .utf8)!

    XCTAssertEqual(encodedString, #""SampleId@warning: Some hint.""#)

    let decodedCheck = try JSONDecoder().decode(Check.self, from: encodedData)
    XCTAssertEqual(decodedCheck.id, "SampleId")
    XCTAssertEqual(decodedCheck.hint, "Some hint.")
    XCTAssertEqual(decodedCheck.severity, .warning)
  }
}
