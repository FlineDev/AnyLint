@testable import Reporting
import Core
import XCTest

final class LintResultsTests: XCTestCase {
  private var sampleLintResults: LintResults {
    [
      Severity.error: [
        CheckInfo(id: "1", hint: "hint #1", severity: .error): [
          Violation(matchedString: "oink", fileLocation: .init(filePath: "/sample/path1", row: 4, column: 2)),
          Violation(matchedString: "boo", fileLocation: .init(filePath: "/sample/path2", row: 40, column: 20)),
          Violation(
            fileLocation: .init(filePath: "/sample/path2"),
            appliedAutoCorrection: .init(before: "foo", after: "bar")
          ),
        ],
        CheckInfo(id: "2", hint: "hint #2", severity: .warning): [
          Violation(matchedString: "oink", fileLocation: .init(filePath: "/sample/path1", row: 5, column: 6)),
          Violation(matchedString: "boo", fileLocation: .init(filePath: "/sample/path3", row: 50, column: 60)),
          Violation(
            fileLocation: .init(filePath: "/sample/path4"),
            appliedAutoCorrection: .init(before: "fool", after: "barl")
          ),
        ],
        CheckInfo(id: "3", hint: "hint #3", severity: .info): [
          Violation(matchedString: "blubb", fileLocation: .init(filePath: "/sample/path0", row: 10, column: 20))
        ],
      ]
    ]
  }

  func testAllExecutedChecks() {
    let allExecutedChecks = sampleLintResults.allExecutedChecks
    XCTAssertEqual(allExecutedChecks.count, 3)
    XCTAssertEqual(allExecutedChecks.map(\.id), ["1", "2", "3"])
  }

  func testAllFoundViolations() {
    let allFoundViolations = sampleLintResults.allFoundViolations
    XCTAssertEqual(allFoundViolations.count, 7)
    XCTAssertEqual(
      allFoundViolations.map(\.fileLocation).map(\.?.filePath).map(\.?.last),
      ["1", "2", "2", "1", "3", "4", "0"]
    )
    XCTAssertEqual(allFoundViolations.map(\.matchedString), ["oink", "boo", nil, "oink", "boo", nil, "blubb"])
  }

  func testMergeResults() {
    let otherLintResults: LintResults = [
      Severity.error: [
        CheckInfo(id: "1", hint: "hint #1", severity: .warning): [
          Violation(matchedString: "muuh", fileLocation: .init(filePath: "/sample/path4", row: 6, column: 3)),
          Violation(
            fileLocation: .init(filePath: "/sample/path5"),
            appliedAutoCorrection: .init(before: "fusion", after: "wario")
          ),
        ],
        CheckInfo(id: "2", hint: "hint #2 (alternative)", severity: .warning): [],
        CheckInfo(id: "4", hint: "hint #4", severity: .error): [
          Violation(matchedString: "super", fileLocation: .init(filePath: "/sample/path1", row: 2, column: 200))
        ],
      ]
    ]

    var lintResults = sampleLintResults
    lintResults.mergeResults(otherLintResults)
    let allExecutedChecks = lintResults.allExecutedChecks
    let allFoundViolations = lintResults.allFoundViolations

    XCTAssertEqual(allExecutedChecks.count, 6)
    XCTAssertEqual(allExecutedChecks.map(\.id), ["1", "2", "3", "1", "2", "4"])

    XCTAssertEqual(allFoundViolations.count, 10)
    XCTAssertEqual(
      allFoundViolations.map(\.fileLocation).map(\.?.filePath).map(\.?.last),
      ["1", "2", "2", "1", "3", "4", "0", "4", "5", "1"]
    )
    XCTAssertEqual(
      allFoundViolations.map(\.matchedString),
      ["oink", "boo", nil, "oink", "boo", nil, "blubb", "muuh", nil, "super"]
    )
  }

  func testAppendViolations() {
    // TODO: [cg_2021-09-01] not yet implemented
    var lintResults = sampleLintResults

    XCTAssertEqual(lintResults.allFoundViolations.count, 7)
    XCTAssertEqual(lintResults.allExecutedChecks.count, 3)
    XCTAssertEqual(
      lintResults.allFoundViolations.map(\.matchedString).map(\.?.first),
      ["o", "b", nil, "o", "b", nil, "b"]
    )
    XCTAssertEqual(lintResults.allExecutedChecks.map(\.id), ["1", "2", "3"])

    lintResults.appendViolations(
      [
        Violation(matchedString: "A", fileLocation: .init(filePath: "/sample/path5", row: 7, column: 7)),
        Violation(matchedString: "B", fileLocation: .init(filePath: "/sample/path6", row: 70, column: 70)),
        Violation(
          fileLocation: .init(filePath: "/sample/path7"),
          appliedAutoCorrection: .init(before: "C", after: "D")
        ),
      ],
      forCheck: .init(id: "Added", hint: "hint for added")
    )

    XCTAssertEqual(lintResults.allFoundViolations.count, 10)
    XCTAssertEqual(lintResults.allExecutedChecks.count, 4)
    XCTAssertEqual(
      lintResults.allFoundViolations.map(\.matchedString).map(\.?.first),
      ["o", "b", nil, "o", "b", nil, "b", "A", "B", nil]
    )
    XCTAssertEqual(lintResults.allExecutedChecks.map(\.id), ["1", "2", "3", "Added"])
  }

  func testReportToConsole() {
    // TODO: [cg_2021-09-01] not yet implemented
  }

  func testReportToXcode() {
    // TODO: [cg_2021-09-01] not yet implemented
  }

  func testReportToFile() {
    // TODO: [cg_2021-09-01] not yet implemented
  }

  func testViolations() {
    // TODO: [cg_2021-09-01] not yet implemented
  }
}
