@testable import AnyLint
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
      violations: [
        Violation(checkInfo: checkInfo3), Violation(checkInfo: checkInfo3), Violation(checkInfo: checkInfo3),
      ],
      in: CheckInfo(id: "id3", hint: "hint3", severity: .error)
    )

    XCTAssertEqual(Statistics.shared.executedChecks, [checkInfo1, checkInfo2, checkInfo3])
    XCTAssertEqual(Statistics.shared.violationsBySeverity[.info]!.count, 1)
    XCTAssertEqual(Statistics.shared.violationsBySeverity[.warning]!.count, 2)
    XCTAssertEqual(Statistics.shared.violationsBySeverity[.error]!.count, 3)
    XCTAssertEqual(Statistics.shared.violationsPerCheck.keys.count, 3)
  }

  func testLogSummary() {  // swiftlint:disable:this function_body_length
    Statistics.shared.logCheckSummary()
    XCTAssertEqual(TestHelper.shared.consoleOutputs.count, 1)
    XCTAssertEqual(TestHelper.shared.consoleOutputs[0].level, .warning)
    XCTAssertEqual(TestHelper.shared.consoleOutputs[0].message, "No checks found to perform.")

    TestHelper.shared.reset()

    let checkInfo1 = CheckInfo(id: "id1", hint: "hint1", severity: .info)
    Statistics.shared.found(
      violations: [Violation(checkInfo: checkInfo1)],
      in: checkInfo1
    )

    let checkInfo2 = CheckInfo(id: "id2", hint: "hint2", severity: .warning)
    Statistics.shared.found(
      violations: [
        Violation(checkInfo: checkInfo2, filePath: "Hogwarts/Harry.swift"),
        Violation(checkInfo: checkInfo2, filePath: "Hogwarts/Albus.swift"),
      ],
      in: CheckInfo(id: "id2", hint: "hint2", severity: .warning)
    )

    let checkInfo3 = CheckInfo(id: "id3", hint: "hint3", severity: .error)
    Statistics.shared.found(
      violations: [
        Violation(checkInfo: checkInfo3, filePath: "Hogwarts/Harry.swift", locationInfo: (line: 10, charInLine: 30)),
        Violation(checkInfo: checkInfo3, filePath: "Hogwarts/Harry.swift", locationInfo: (line: 72, charInLine: 17)),
        Violation(checkInfo: checkInfo3, filePath: "Hogwarts/Albus.swift", locationInfo: (line: 40, charInLine: 4)),
      ],
      in: CheckInfo(id: "id3", hint: "hint3", severity: .error)
    )

    Statistics.shared.checkedFiles(at: ["Hogwarts/Harry.swift"])
    Statistics.shared.checkedFiles(at: ["Hogwarts/Harry.swift", "Hogwarts/Albus.swift"])
    Statistics.shared.checkedFiles(at: ["Hogwarts/Albus.swift"])

    Statistics.shared.logCheckSummary()

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
