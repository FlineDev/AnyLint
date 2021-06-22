@testable import Utility
import XCTest

final class LoggerTests: XCTestCase {
  override func setUp() {
    log = Logger(outputType: .test)
    TestHelper.shared.reset()
  }

  func testMessage() {
    XCTAssert(TestHelper.shared.consoleOutputs.isEmpty)

    log.message("Test", level: .info)

    XCTAssertEqual(TestHelper.shared.consoleOutputs.count, 1)
    XCTAssertEqual(TestHelper.shared.consoleOutputs[0].level, .info)
    XCTAssertEqual(TestHelper.shared.consoleOutputs[0].message, "Test")

    log.message("Test 2", level: .warning)

    XCTAssertEqual(TestHelper.shared.consoleOutputs.count, 2)
    XCTAssertEqual(TestHelper.shared.consoleOutputs[1].level, .warning)
    XCTAssertEqual(TestHelper.shared.consoleOutputs[1].message, "Test 2")

    log.message("Test 3", level: .error)

    XCTAssertEqual(TestHelper.shared.consoleOutputs.count, 3)
    XCTAssertEqual(TestHelper.shared.consoleOutputs[2].level, .error)
    XCTAssertEqual(TestHelper.shared.consoleOutputs[2].message, "Test 3")
  }
}
