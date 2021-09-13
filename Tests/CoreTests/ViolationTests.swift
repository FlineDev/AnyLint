@testable import Core
import XCTest

final class ViolationTests: XCTestCase {
  func testLocationMessage() {
    XCTAssertNil(Violation().location?.locationMessage(pathType: .relative))

    let fileViolation = Violation(location: .init(filePath: "Temp/Sources/Hello.swift"))
    XCTAssertEqual(fileViolation.location?.locationMessage(pathType: .relative), "Temp/Sources/Hello.swift")

    let locationInfoViolation = Violation(location: .init(filePath: "Temp/Sources/World.swift", row: 5, column: 15))
    XCTAssertEqual(
      locationInfoViolation.location?.locationMessage(pathType: .relative),
      "Temp/Sources/World.swift:5:15:"
    )
  }
}
