@testable import Core
import XCTest

final class ViolationTests: XCTestCase {
  func testLocationMessage() {
    XCTAssertNil(Violation().locationMessage(pathType: .relative))

    let fileViolation = Violation(filePath: "Temp/Souces/Hello.swift")
    XCTAssertEqual(fileViolation.locationMessage(pathType: .relative), "Temp/Souces/Hello.swift")

    let locationInfoViolation = Violation(
      filePath: "Temp/Souces/World.swift",
      fileLocation: .init(row: 5, column: 15)
    )

    XCTAssertEqual(locationInfoViolation.locationMessage(pathType: .relative), "Temp/Souces/World.swift:5:15:")
  }
}
