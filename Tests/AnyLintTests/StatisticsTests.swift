@testable import AnyLint
@testable import Utility
import XCTest

final class StatisticsTests: XCTestCase {
    override func setUp() {
        log = Logger(outputType: .test)
        TestHelper.shared.reset()
        Statistics.shared.reset()
    }

    func testFoundViolationsInCheck() {
        XCTAssert(Statistics.shared.executedChecks.isEmpty)
        XCTAssert(Statistics.shared.violationsBySeverity[.info]!.isEmpty)
        XCTAssert(Statistics.shared.violationsBySeverity[.warning]!.isEmpty)
        XCTAssert(Statistics.shared.violationsBySeverity[.error]!.isEmpty)
        XCTAssert(Statistics.shared.violationsPerCheck.isEmpty)

        let checkInfo1 = CheckInfo(id: "id1", hint: "hint1", severity: .info)
        Statistics.shared.found(
            violations: [Violation(checkInfo: checkInfo1)],
            in: checkInfo1
        )

        XCTAssertEqual(Statistics.shared.executedChecks, [checkInfo1])
        XCTAssertEqual(Statistics.shared.violationsBySeverity[.info]!.count, 1)
        XCTAssertEqual(Statistics.shared.violationsBySeverity[.warning]!.count, 0)
        XCTAssertEqual(Statistics.shared.violationsBySeverity[.error]!.count, 0)
        XCTAssertEqual(Statistics.shared.violationsPerCheck.keys.count, 1)

        let checkInfo2 = CheckInfo(id: "id2", hint: "hint2", severity: .warning)
        Statistics.shared.found(
            violations: [Violation(checkInfo: checkInfo2), Violation(checkInfo: checkInfo2)],
            in: CheckInfo(id: "id2", hint: "hint2", severity: .warning)
        )

        XCTAssertEqual(Statistics.shared.executedChecks, [checkInfo1, checkInfo2])
        XCTAssertEqual(Statistics.shared.violationsBySeverity[.info]!.count, 1)
        XCTAssertEqual(Statistics.shared.violationsBySeverity[.warning]!.count, 2)
        XCTAssertEqual(Statistics.shared.violationsBySeverity[.error]!.count, 0)
        XCTAssertEqual(Statistics.shared.violationsPerCheck.keys.count, 2)

        let checkInfo3 = CheckInfo(id: "id3", hint: "hint3", severity: .error)
        Statistics.shared.found(
            violations: [Violation(checkInfo: checkInfo3), Violation(checkInfo: checkInfo3), Violation(checkInfo: checkInfo3)],
            in: CheckInfo(id: "id3", hint: "hint3", severity: .error)
        )

        XCTAssertEqual(Statistics.shared.executedChecks, [checkInfo1, checkInfo2, checkInfo3])
        XCTAssertEqual(Statistics.shared.violationsBySeverity[.info]!.count, 1)
        XCTAssertEqual(Statistics.shared.violationsBySeverity[.warning]!.count, 2)
        XCTAssertEqual(Statistics.shared.violationsBySeverity[.error]!.count, 3)
        XCTAssertEqual(Statistics.shared.violationsPerCheck.keys.count, 3)
    }

    func testLogSummary() {
        Statistics.shared.logSummary()
        XCTAssertEqual(TestHelper.shared.consoleOutputs.count, 1)
        XCTAssertEqual(TestHelper.shared.consoleOutputs[0].level, .warning)
        XCTAssertEqual(TestHelper.shared.consoleOutputs[0].message, "No checks found to perform.")

        let checkInfo1 = CheckInfo(id: "id1", hint: "hint1", severity: .info)
        Statistics.shared.found(
            violations: [Violation(checkInfo: checkInfo1)],
            in: checkInfo1
        )

        let checkInfo2 = CheckInfo(id: "id2", hint: "hint2", severity: .warning)
        Statistics.shared.found(
            violations: [Violation(checkInfo: checkInfo2), Violation(checkInfo: checkInfo2)],
            in: CheckInfo(id: "id2", hint: "hint2", severity: .warning)
        )

        let checkInfo3 = CheckInfo(id: "id3", hint: "hint3", severity: .error)
        Statistics.shared.found(
            violations: [Violation(checkInfo: checkInfo3), Violation(checkInfo: checkInfo3), Violation(checkInfo: checkInfo3)],
            in: CheckInfo(id: "id3", hint: "hint3", severity: .error)
        )

        Statistics.shared.logSummary()
        XCTAssertEqual(TestHelper.shared.consoleOutputs.count, 2)
        XCTAssertEqual(TestHelper.shared.consoleOutputs[1].level, .error)
        XCTAssertEqual(TestHelper.shared.consoleOutputs[1].message, "Performed 3 checks and found 3 errors & 2 warnings.")
    }
}
