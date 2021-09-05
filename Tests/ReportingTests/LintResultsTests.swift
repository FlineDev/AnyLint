@testable import Reporting
import Core
import XCTest
import CustomDump

final class LintResultsTests: XCTestCase {
  private var sampleLintResults: LintResults {
    [
      Severity.error: [
        CheckInfo(id: "1", hint: "hint #1", severity: .error): [
          Violation(matchedString: "oink1", fileLocation: .init(filePath: "/sample/path1", row: 4, column: 2)),
          Violation(matchedString: "boo1", fileLocation: .init(filePath: "/sample/path2", row: 40, column: 20)),
          Violation(
            fileLocation: .init(filePath: "/sample/path2"),
            appliedAutoCorrection: .init(before: "foo", after: "bar")
          ),
        ]
      ],
      Severity.warning: [
        CheckInfo(id: "2", hint: "hint #2", severity: .warning): [
          Violation(matchedString: "oink2", fileLocation: .init(filePath: "/sample/path1", row: 5, column: 6)),
          Violation(matchedString: "boo2", fileLocation: .init(filePath: "/sample/path3", row: 50, column: 60)),
          Violation(
            fileLocation: .init(filePath: "/sample/path4"),
            appliedAutoCorrection: .init(before: "fool", after: "barl")
          ),
        ]
      ],
      Severity.info: [
        CheckInfo(id: "3", hint: "hint #3", severity: .info): [
          Violation(matchedString: "blubb", fileLocation: .init(filePath: "/sample/path0", row: 10, column: 20))
        ]
      ],
    ]
  }

  func testAllExecutedChecks() {
    let allExecutedChecks = sampleLintResults.allExecutedChecks
    XCTAssertNoDifference(allExecutedChecks.count, 3)
    XCTAssertNoDifference(allExecutedChecks.map(\.id), ["1", "2", "3"])
  }

  func testAllFoundViolations() {
    let allFoundViolations = sampleLintResults.allFoundViolations
    XCTAssertNoDifference(allFoundViolations.count, 7)
    XCTAssertNoDifference(
      allFoundViolations.map(\.fileLocation).map(\.?.filePath).map(\.?.last),
      ["1", "2", "2", "1", "3", "4", "0"]
    )
    XCTAssertNoDifference(
      allFoundViolations.map(\.matchedString),
      ["oink1", "boo1", nil, "oink2", "boo2", nil, "blubb"]
    )
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

    XCTAssertNoDifference(allExecutedChecks.count, 6)
    XCTAssertNoDifference(allExecutedChecks.map(\.id), ["1", "1", "2", "4", "2", "3"])

    XCTAssertNoDifference(allFoundViolations.count, 10)
    XCTAssertNoDifference(
      allFoundViolations.map(\.fileLocation).map(\.?.filePath).map(\.?.last),
      ["1", "2", "2", "4", "5", "1", "1", "3", "4", "0"]
    )
    XCTAssertNoDifference(
      allFoundViolations.map(\.matchedString),
      ["oink1", "boo1", nil, "muuh", nil, "super", "oink2", "boo2", nil, "blubb"]
    )
  }

  func testAppendViolations() {
    // TODO: [cg_2021-09-01] not yet implemented
    var lintResults = sampleLintResults

    XCTAssertNoDifference(lintResults.allFoundViolations.count, 7)
    XCTAssertNoDifference(lintResults.allExecutedChecks.count, 3)
    XCTAssertNoDifference(
      lintResults.allFoundViolations.map(\.matchedString).map(\.?.first),
      ["o", "b", nil, "o", "b", nil, "b"]
    )
    XCTAssertNoDifference(lintResults.allExecutedChecks.map(\.id), ["1", "2", "3"])

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

    XCTAssertNoDifference(lintResults.allFoundViolations.count, 10)
    XCTAssertNoDifference(lintResults.allExecutedChecks.count, 4)
    XCTAssertNoDifference(
      lintResults.allFoundViolations.map(\.matchedString).map(\.?.first),
      ["o", "b", nil, "A", "B", nil, "o", "b", nil, "b"]
    )
    XCTAssertNoDifference(lintResults.allExecutedChecks.map(\.id), ["1", "Added", "2", "3"])
  }

  func testReportToConsole() {
    let testLogger = TestLogger()
    log = testLogger

    XCTAssertNoDifference(testLogger.loggedMessages, [])
    sampleLintResults.reportToConsole()

    XCTAssertNoDifference(
      testLogger.loggedMessages,
      [
        "[error] [1] Found 3 violation(s) at:",
        "[error] > 1. /sample/path1:4:2:",
        "[info]      Matching string: (trimmed & reduced whitespaces)",
        "[info]      > oink1",
        "[error] > 2. /sample/path2:40:20:",
        "[info]      Matching string: (trimmed & reduced whitespaces)",
        "[info]      > boo1",
        "[error] > 3. /sample/path2",
        "[info]      Autocorrection applied, the diff is: (+ added, - removed)",
        "[info]      - foo",
        "[info]      + bar",
        "[error] >> Hint: hint #1",
        "[warning] [2] Found 3 violation(s) at:",
        "[warning] > 1. /sample/path1:5:6:",
        "[info]      Matching string: (trimmed & reduced whitespaces)",
        "[info]      > oink2",
        "[warning] > 2. /sample/path3:50:60:",
        "[info]      Matching string: (trimmed & reduced whitespaces)",
        "[info]      > boo2",
        "[warning] > 3. /sample/path4",
        "[info]      Autocorrection applied, the diff is: (+ added, - removed)",
        "[info]      - fool",
        "[info]      + barl",
        "[warning] >> Hint: hint #2",
        "[info] [3] Found 1 violation(s) at:",
        "[info] > 1. /sample/path0:10:20:",
        "[info]      Matching string: (trimmed & reduced whitespaces)",
        "[info]      > blubb",
        "[info] >> Hint: hint #3",
        "[error] Performed 3 check(s) and found 3 error(s) & 3 warning(s).",
      ]
    )
  }

  func testReportToXcode() {
    let testLogger = TestLogger()
    log = testLogger

    XCTAssertNoDifference(testLogger.loggedMessages, [])
    sampleLintResults.reportToXcode()

    XCTAssertNoDifference(
      testLogger.loggedMessages,
      [
        "[error] /sample/path1:4:2: [1] hint #1",
        "[error] /sample/path2:40:20: [1] hint #1",
        "[warning] /sample/path1:5:6: [2] hint #2",
        "[warning] /sample/path3:50:60: [2] hint #2",
        "[info] /sample/path0:10:20: [3] hint #3",
      ]
    )
  }

  func testReportToFile() throws {
    let resultFileUrl = URL(fileURLWithPath: "anylint-test-results.json")

    if FileManager.default.fileExists(atPath: resultFileUrl.path) {
      try FileManager.default.removeItem(at: resultFileUrl)
    }
    XCTAssertFalse(FileManager.default.fileExists(atPath: resultFileUrl.path))

    sampleLintResults.reportToFile(at: resultFileUrl.path)
    XCTAssert(FileManager.default.fileExists(atPath: resultFileUrl.path))

    let reportedContents = try Data(contentsOf: resultFileUrl)
    let reportedLintResults = try JSONDecoder.iso.decode(LintResults.self, from: reportedContents)

    XCTAssertNoDifference(sampleLintResults.map(\.key), reportedLintResults.map(\.key))
  }

  func testViolations() {
    let lintResults = sampleLintResults

    XCTAssertNoDifference(
      lintResults.violations(severity: .warning, excludeAutocorrected: false).map(\.matchedString),
      ["oink2", "boo2", nil]
    )

    XCTAssertNoDifference(
      lintResults.violations(severity: .warning, excludeAutocorrected: true).map(\.matchedString),
      ["oink2", "boo2"]
    )

    XCTAssertNoDifference(
      lintResults
        .violations(check: .init(id: "1", hint: "hint #1"), excludeAutocorrected: false).map(\.matchedString),
      ["oink1", "boo1", nil]
    )

    XCTAssertNoDifference(
      lintResults
        .violations(check: .init(id: "1", hint: "hint #1"), excludeAutocorrected: true).map(\.matchedString),
      ["oink1", "boo1"]
    )
  }

  func testMaxViolationSeverity() {
    var lintResults: LintResults = sampleLintResults
    XCTAssertEqual(sampleLintResults.maxViolationSeverity(excludeAutocorrected: false), .error)

    lintResults = [
      Severity.error: [
        CheckInfo(id: "1", hint: "hint #1", severity: .error): []
      ],
      Severity.warning: [
        CheckInfo(id: "2", hint: "hint #2", severity: .warning): [
          Violation(matchedString: "oink2", fileLocation: .init(filePath: "/sample/path1", row: 5, column: 6)),
          Violation(matchedString: "boo2", fileLocation: .init(filePath: "/sample/path3", row: 50, column: 60)),
          Violation(
            fileLocation: .init(filePath: "/sample/path4"),
            appliedAutoCorrection: .init(before: "fool", after: "barl")
          ),
        ]
      ],
      Severity.info: [
        CheckInfo(id: "3", hint: "hint #3", severity: .info): [
          Violation(matchedString: "blubb", fileLocation: .init(filePath: "/sample/path0", row: 10, column: 20))
        ]
      ],
    ]
    XCTAssertEqual(lintResults.maxViolationSeverity(excludeAutocorrected: false), .warning)

    lintResults = [
      Severity.error: [
        CheckInfo(id: "1", hint: "hint #1", severity: .error): []
      ],
      Severity.warning: [
        CheckInfo(id: "2", hint: "hint #2", severity: .warning): []
      ],
      Severity.info: [
        CheckInfo(id: "3", hint: "hint #3", severity: .info): [
          Violation(matchedString: "blubb", fileLocation: .init(filePath: "/sample/path0", row: 10, column: 20))
        ]
      ],
    ]
    XCTAssertEqual(lintResults.maxViolationSeverity(excludeAutocorrected: false), .info)

    lintResults = [
      Severity.error: [
        CheckInfo(id: "1", hint: "hint #1", severity: .error): []
      ],
      Severity.warning: [
        CheckInfo(id: "2", hint: "hint #2", severity: .warning): []
      ],
      Severity.info: [
        CheckInfo(id: "3", hint: "hint #3", severity: .info): []
      ],
    ]
    XCTAssertEqual(lintResults.maxViolationSeverity(excludeAutocorrected: false), nil)

    XCTAssertEqual(LintResults().maxViolationSeverity(excludeAutocorrected: false), nil)
  }
}
