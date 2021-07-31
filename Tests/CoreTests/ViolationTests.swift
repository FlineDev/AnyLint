@testable import Core
import XCTest

final class ViolationTests: XCTestCase {
  func testSample() {
    XCTAssertTrue(true)  // TODO: [cg_2021-07-31] not yet implemented
  }

  //  func testLocationMessage() {
  //    let checkInfo = CheckInfo(id: "demo_check", hint: "Make sure to always check the demo.", severity: .warning)
  //    XCTAssertNil(Violation(checkInfo: checkInfo).locationMessage(pathType: .relative))
  //
  //    let fileViolation = Violation(checkInfo: checkInfo, filePath: "Temp/Souces/Hello.swift")
  //    XCTAssertEqual(fileViolation.locationMessage(pathType: .relative), "Temp/Souces/Hello.swift")
  //
  //    let locationInfoViolation = Violation(
  //      checkInfo: checkInfo,
  //      filePath: "Temp/Souces/World.swift",
  //      locationInfo: String.LocationInfo(line: 5, charInLine: 15)
  //    )
  //
  //    XCTAssertEqual(locationInfoViolation.locationMessage(pathType: .relative), "Temp/Souces/World.swift:5:15:")
  //  }
}
