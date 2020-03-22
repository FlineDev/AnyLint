@testable import AnyLint
@testable import Utility
import XCTest

final class CheckInfoTests: XCTestCase {
    override func setUp() {
        log = Logger(outputType: .test)
        TestHelper.shared.reset()
    }

    func testInitWithStringLiteral() {
        XCTAssert(TestHelper.shared.consoleOutputs.isEmpty)

        let checkInfo1: CheckInfo = "test1@error: hint1"
        XCTAssertEqual(checkInfo1.id, "test1")
        XCTAssertEqual(checkInfo1.hint, "hint1")
        XCTAssertEqual(checkInfo1.severity, .error)

        let checkInfo2: CheckInfo = "test2@warning: hint2"
        XCTAssertEqual(checkInfo2.id, "test2")
        XCTAssertEqual(checkInfo2.hint, "hint2")
        XCTAssertEqual(checkInfo2.severity, .warning)

        let checkInfo3: CheckInfo = "test3@info: hint3"
        XCTAssertEqual(checkInfo3.id, "test3")
        XCTAssertEqual(checkInfo3.hint, "hint3")
        XCTAssertEqual(checkInfo3.severity, .info)

        let checkInfo4: CheckInfo = "test4: hint4"
        XCTAssertEqual(checkInfo4.id, "test4")
        XCTAssertEqual(checkInfo4.hint, "hint4")
        XCTAssertEqual(checkInfo4.severity, .error)
    }
}
