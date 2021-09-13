@testable import Core
import XCTest

final class SeverityTests: XCTestCase {
  func testComparable() throws {
    XCTAssert(Severity.error > Severity.warning)
    XCTAssert(Severity.warning > Severity.info)
    XCTAssert(Severity.error > Severity.info)
    XCTAssert(Severity.warning < Severity.error)
    XCTAssert(Severity.info < Severity.warning)
    XCTAssert(Severity.info < Severity.error)
    XCTAssert(Severity.error == Severity.error)
    XCTAssert(Severity.warning == Severity.warning)
    XCTAssert(Severity.info == Severity.info)
  }
}
