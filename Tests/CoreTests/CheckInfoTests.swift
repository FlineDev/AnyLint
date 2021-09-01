@testable import Core
import XCTest

final class CheckInfoTests: XCTestCase {
  func testInit() {
    let checkInfo = CheckInfo(id: "SampleId", hint: "Some hint.", severity: .warning)
    XCTAssertEqual(checkInfo.id, "SampleId")
    XCTAssertEqual(checkInfo.hint, "Some hint.")
    XCTAssertEqual(checkInfo.severity, .warning)

    XCTAssertEqual(CheckInfo(id: "id", hint: "hint").severity, .error)
  }

  func testCodable() throws {
    let checkInfo = CheckInfo(id: "SampleId", hint: "Some hint.", severity: .warning)
    let encodedData = try JSONEncoder().encode(checkInfo)
    let encodedString = String(data: encodedData, encoding: .utf8)!

    XCTAssertEqual(encodedString, #""SampleId@warning: Some hint.""#)

    let decodedCheckInfo = try JSONDecoder().decode(CheckInfo.self, from: encodedData)
    XCTAssertEqual(decodedCheckInfo.id, "SampleId")
    XCTAssertEqual(decodedCheckInfo.hint, "Some hint.")
    XCTAssertEqual(decodedCheckInfo.severity, .warning)
  }
}
