@testable import Core
import XCTest

final class ViolationTests: XCTestCase {
  func testLocationMessage() {
    XCTAssertNil(Violation().fileLocation?.locationMessage(pathType: .relative))

    let fileViolation = Violation(fileLocation: .init(filePath: "Temp/Sources/Hello.swift"))
    XCTAssertEqual(fileViolation.fileLocation?.locationMessage(pathType: .relative), "Temp/Sources/Hello.swift")

    let locationInfoViolation = Violation(fileLocation: .init(filePath: "Temp/Sources/World.swift", row: 5, column: 15))
    XCTAssertEqual(
      locationInfoViolation.fileLocation?.locationMessage(pathType: .relative),
      "Temp/Sources/World.swift:5:15:"
    )
  }
}
