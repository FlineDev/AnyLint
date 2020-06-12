@testable import AnyLint
import Rainbow
@testable import Utility
import XCTest

final class StatisticsTests: XCTestCase {
    override func setUp() {
        log = Logger(outputType: .test)
        TestHelper.shared.reset()
        Statistics.default.reset()
    }

    func testFoundViolationsInCheck() {
        XCTAssert(Statistics.default.executedChecks.isEmpty)
        XCTAssert(Statistics.default.violationsBySeverity[.info]!.isEmpty)
        XCTAssert(Statistics.default.violationsBySeverity[.warning]!.isEmpty)
        XCTAssert(Statistics.default.violationsBySeverity[.error]!.isEmpty)
        XCTAssert(Statistics.default.violationsPerCheck.isEmpty)

        let checkInfo1 = CheckInfo(id: "id1", hint: "hint1", severity: .info)
        Statistics.default.found(violations: [checkInfo1: [Violation(checkInfo: checkInfo1)]])

        XCTAssertEqual(Statistics.default.executedChecks, [checkInfo1])
        XCTAssertEqual(Statistics.default.violationsBySeverity[.info]!.count, 1)
        XCTAssertEqual(Statistics.default.violationsBySeverity[.warning]!.count, 0)
        XCTAssertEqual(Statistics.default.violationsBySeverity[.error]!.count, 0)
        XCTAssertEqual(Statistics.default.violationsPerCheck.keys.count, 1)

        let checkInfo2 = CheckInfo(id: "id2", hint: "hint2", severity: .warning)
        Statistics.default.found(
            violations: [
                CheckInfo(id: "id2", hint: "hint2", severity: .warning):
                    [Violation(checkInfo: checkInfo2), Violation(checkInfo: checkInfo2)]
            ]
        )

        XCTAssertEqual(Statistics.default.executedChecks, [checkInfo1, checkInfo2])
        XCTAssertEqual(Statistics.default.violationsBySeverity[.info]!.count, 1)
        XCTAssertEqual(Statistics.default.violationsBySeverity[.warning]!.count, 2)
        XCTAssertEqual(Statistics.default.violationsBySeverity[.error]!.count, 0)
        XCTAssertEqual(Statistics.default.violationsPerCheck.keys.count, 2)

        let checkInfo3 = CheckInfo(id: "id3", hint: "hint3", severity: .error)
        Statistics.default.found(
            violations: [
                CheckInfo(id: "id3", hint: "hint3", severity: .error):
                [Violation(checkInfo: checkInfo3), Violation(checkInfo: checkInfo3), Violation(checkInfo: checkInfo3)]
            ]
        )

        XCTAssertEqual(Statistics.default.executedChecks, [checkInfo1, checkInfo2, checkInfo3])
        XCTAssertEqual(Statistics.default.violationsBySeverity[.info]!.count, 1)
        XCTAssertEqual(Statistics.default.violationsBySeverity[.warning]!.count, 2)
        XCTAssertEqual(Statistics.default.violationsBySeverity[.error]!.count, 3)
        XCTAssertEqual(Statistics.default.violationsPerCheck.keys.count, 3)
    }

    func testLogSummary() { // swiftlint:disable:this function_body_length
        Statistics.default.logCheckSummary()
        XCTAssertEqual(TestHelper.shared.consoleOutputs.count, 1)
        XCTAssertEqual(TestHelper.shared.consoleOutputs[0].level, .warning)
        XCTAssertEqual(TestHelper.shared.consoleOutputs[0].message, "No checks found to perform.")

        TestHelper.shared.reset()

        let checkInfo1 = CheckInfo(id: "id1", hint: "hint1", severity: .info)
        Statistics.default.found(violations: [checkInfo1: [Violation(checkInfo: checkInfo1)]])

        let checkInfo2 = CheckInfo(id: "id2", hint: "hint2", severity: .warning)
        Statistics.default.found(
            violations: [
                CheckInfo(id: "id2", hint: "hint2", severity: .warning):
                    [
                        Violation(checkInfo: checkInfo2, filePath: "Hogwarts/Harry.swift"),
                        Violation(checkInfo: checkInfo2, filePath: "Hogwarts/Albus.swift"),
                    ]
            ]
        )

        let checkInfo3 = CheckInfo(id: "id3", hint: "hint3", severity: .error)
        Statistics.default.found(
            violations: [
                CheckInfo(id: "id3", hint: "hint3", severity: .error):
                    [
                        Violation(
                            checkInfo: checkInfo3,
                            filePath: "Hogwarts/Harry.swift",
                            locationInfo: String.LocationInfo(line: 10, charInLine: 30)
                        ),
                        Violation(
                            checkInfo: checkInfo3,
                            filePath: "Hogwarts/Harry.swift",
                            locationInfo: String.LocationInfo(line: 72, charInLine: 17)
                        ),
                        Violation(
                            checkInfo: checkInfo3,
                            filePath: "Hogwarts/Albus.swift",
                            locationInfo: String.LocationInfo(line: 40, charInLine: 4)
                        ),
                    ]
            ]
        )

        Statistics.default.checkedFiles(at: ["Hogwarts/Harry.swift"])
        Statistics.default.checkedFiles(at: ["Hogwarts/Harry.swift", "Hogwarts/Albus.swift"])
        Statistics.default.checkedFiles(at: ["Hogwarts/Albus.swift"])

        Statistics.default.logCheckSummary()

        XCTAssertEqual(
            TestHelper.shared.consoleOutputs.map { $0.level },
            [.info, .info, .warning, .warning, .warning, .warning, .error, .error, .error, .error, .error, .error]
        )

        let expectedOutputs = [
            "\("[id1]".bold) Found 1 violation(s).",
            ">> Hint: hint1".bold.italic,
            "\("[id2]".bold) Found 2 violation(s) at:",
            "> 1. Hogwarts/Harry.swift",
            "> 2. Hogwarts/Albus.swift",
            ">> Hint: hint2".bold.italic,
            "\("[id3]".bold) Found 3 violation(s) at:",
            "> 1. Hogwarts/Harry.swift:10:30:",
            "> 2. Hogwarts/Harry.swift:72:17:",
            "> 3. Hogwarts/Albus.swift:40:4:",
            ">> Hint: hint3".bold.italic,
            "Performed 3 check(s) in 2 file(s) and found 3 error(s) & 2 warning(s).",
        ]

        XCTAssertEqual(TestHelper.shared.consoleOutputs.count, expectedOutputs.count)

        for (index, expectedOutput) in expectedOutputs.enumerated() {
            XCTAssertEqual(TestHelper.shared.consoleOutputs[index].message, expectedOutput)
        }
    }
}
