@testable import Checkers
import XCTest
import Core
import TestSupport
import CustomDump
import Reporting

final class LintTests: XCTestCase {
  var testLogger: TestLogger = .init()

  override func setUp() {
    testLogger = TestLogger()
    log = testLogger
  }

  func testValidateRegexMatchesForEach() {
    XCTAssertNil(testLogger.exitStatusCode)

    let regex = try! Regex(#"foo[0-9]?bar"#)
    let check = Check(id: "foo_bar", hint: "do bar", severity: .warning)

    Lint.validate(
      regex: regex,
      matchesForEach: ["foo1bar", "foobar", "myfoo4barbeque"],
      check: check
    )
    XCTAssertNil(testLogger.exitStatusCode)

    // TODO: [cg_2021-09-05] Swift / XCTest doesn't have a way to test for functions returning `Never`
    //    Lint.validate(
    //      regex: regex,
    //      matchesForEach: ["foo1bar", "FooBar", "myfoo4barbeque"],
    //      check: check
    //    )
    //    XCTAssertEqual(testLogger.exitStatusCode, EXIT_FAILURE)
  }

  func testValidateRegexDoesNotMatchAny() {
    XCTAssertNil(testLogger.exitStatusCode)

    let regex = try! Regex(#"foo[0-9]?bar"#)
    let check = Check(id: "foo_bar", hint: "do bar", severity: .warning)

    Lint.validate(
      regex: regex,
      doesNotMatchAny: ["fooLbar", "FooBar", "myfoo40barbeque"],
      check: check
    )
    XCTAssertNil(testLogger.exitStatusCode)

    // TODO: [cg_2021-09-05] Swift / XCTest doesn't have a way to test for functions returning `Never`
    //    Lint.validate(
    //      regex: regex,
    //      doesNotMatchAny: ["fooLbar", "foobar", "myfoo40barbeque"],
    //      check: check
    //    )
    //    XCTAssertEqual(testLogger.exitStatusCode, EXIT_FAILURE)
  }

  func testValidateAutocorrectsAllExamplesWithAnonymousGroups() {
    XCTAssertNil(testLogger.exitStatusCode)

    let anonymousCaptureRegex = try? Regex(#"([^\.]+)(\.)([^\.]+)(\.)([^\.]+)"#)

    Lint.validateAutocorrectsAll(
      check: Check(id: "id", hint: "hint"),
      examples: [
        AutoCorrection(before: "prefix.content.suffix", after: "suffix.content.prefix"),
        AutoCorrection(before: "forums.swift.org", after: "org.swift.forums"),
      ],
      regex: anonymousCaptureRegex!,
      autocorrectReplacement: "$5$2$3$4$1"
    )

    XCTAssertNil(testLogger.exitStatusCode)

    // TODO: [cg_2021-09-05] Swift / XCTest doesn't have a way to test for functions returning `Never`
    //    Lint.validateAutocorrectsAll(
    //      check: Check(id: "id", hint: "hint"),
    //      examples: [
    //        AutoCorrection(before: "prefix.content.suffix", after: "suffix.content.prefix"),
    //        AutoCorrection(before: "forums.swift.org", after: "org.swift.forums"),
    //      ],
    //      regex: anonymousCaptureRegex!,
    //      autocorrectReplacement: "$4$1$2$3$0"
    //    )
    //
    //    XCTAssertEqual(testLogger.exitStatusCode, EXIT_FAILURE)
  }

  func testValidateAutocorrectsAllExamplesWithNamedGroups() {
    XCTAssertNil(testLogger.exitStatusCode)

    let namedCaptureRegex = try! Regex(#"([^\.]+)\.([^\.]+)\.([^\.]+)"#)

    Lint.validateAutocorrectsAll(
      check: Check(id: "id", hint: "hint"),
      examples: [
        AutoCorrection(before: "prefix.content.suffix", after: "suffix.content.prefix"),
        AutoCorrection(before: "forums.swift.org", after: "org.swift.forums"),
      ],
      regex: namedCaptureRegex,
      autocorrectReplacement: "$3.$2.$1"
    )

    XCTAssertNil(testLogger.exitStatusCode)

    // TODO: [cg_2021-09-05] Swift / XCTest doesn't have a way to test for functions returning `Never`
    //    Lint.validateAutocorrectsAll(
    //      check: Check(id: "id", hint: "hint"),
    //      examples: [
    //        AutoCorrection(before: "prefix.content.suffix", after: "suffix.content.prefix"),
    //        AutoCorrection(before: "forums.swift.org", after: "org.swift.forums"),
    //      ],
    //      regex: namedCaptureRegex,
    //      autocorrectReplacement: "$sfx$sep1$cnt$sep2$pref"
    //    )
    //
    //    XCTAssertEqual(testLogger.exitStatusCode, EXIT_FAILURE)
  }

  func testRunCustomScript() throws {
    var lintResults: LintResults = try Lint.runCustomScript(
      check: .init(id: "1", hint: "hint #1"),
      command: #"""
        if which echo > /dev/null; then
          echo 'Executed custom checks with following result:
          {
            "warning": {
              "A@warning: hint for A": [
                { "discoverDate": "2001-01-01T00:00:00Z" },
                { "discoverDate" : "2001-01-01T01:00:00Z", "matchedString": "A" },
                {
                  "discoverDate" : "2001-01-01T02:00:00Z",
                  "matchedString": "AAA",
                  "location": { "filePath": "\/some\/path", "row": 5 },
                  "appliedAutoCorrection": { "before": "AAA", "after": "A" }
                }
              ]
            },
            "info": {
              "B@info: hint for B": []
            }
          }

          Total: 0 errors, 3 warnings, 0 info.'
        fi

        """#
    )

    XCTAssertNoDifference(lintResults.allExecutedChecks.map(\.id), ["A", "B"])
    XCTAssertEqual(lintResults.allFoundViolations.count, 3)
    XCTAssertNoDifference(lintResults.allFoundViolations.map(\.matchedString), [nil, "A", "AAA"])
    XCTAssertEqual(lintResults.allFoundViolations[2].location?.filePath, "/some/path")
    XCTAssertEqual(lintResults.allFoundViolations[2].location?.row, 5)
    XCTAssertEqual(lintResults.allFoundViolations[2].appliedAutoCorrection?.after, "A")
    XCTAssertNil(lintResults.checkViolationsBySeverity[.error]?.keys.first)
    XCTAssertEqual(lintResults.checkViolationsBySeverity[.info]?.keys.first?.id, "B")

    lintResults = try Lint.runCustomScript(
      check: .init(id: "1", hint: "hint #1", severity: .info),
      command: #"""
        if which echo > /dev/null; then
          echo 'Executed custom check with following violations:
          [
            { "discoverDate": "2001-01-01T00:00:00Z" },
            { "discoverDate" : "2001-01-01T01:00:00Z", "matchedString": "A" },
            {
              "discoverDate" : "2001-01-01T02:00:00Z",
              "matchedString": "AAA",
              "location": { "filePath": "\/some\/path", "row": 5 },
              "appliedAutoCorrection": { "before": "AAA", "after": "A" }
            }
          ]

          Total: 0 errors, 3 warnings, 0 info.'
        fi

        """#
    )

    XCTAssertNoDifference(lintResults.allExecutedChecks.map(\.id), ["1"])
    XCTAssertEqual(lintResults.allFoundViolations.count, 3)
    XCTAssertNoDifference(lintResults.allFoundViolations.map(\.matchedString), [nil, "A", "AAA"])
    XCTAssertEqual(lintResults.allFoundViolations[2].location?.filePath, "/some/path")
    XCTAssertEqual(lintResults.allFoundViolations[2].location?.row, 5)
    XCTAssertEqual(lintResults.allFoundViolations[2].appliedAutoCorrection?.after, "A")
    XCTAssertNil(lintResults.checkViolationsBySeverity[.error]?.keys.first)
    XCTAssertEqual(lintResults.checkViolationsBySeverity[.info]?.keys.first?.id, "1")

    lintResults = try Lint.runCustomScript(
      check: .init(id: "1", hint: "hint #1", severity: .info),
      command:
        "echo 'Executed custom check with 100 files.\nCustom check failed, please check file at path /some/path.' && exit 1"
    )

    XCTAssertNoDifference(lintResults.allExecutedChecks.map(\.id), ["1"])
    XCTAssertEqual(lintResults.allFoundViolations.count, 1)
    XCTAssertNoDifference(
      lintResults.allFoundViolations.map(\.message),
      ["Custom check failed, please check file at path /some/path."]
    )
    XCTAssertNil(lintResults.checkViolationsBySeverity[.error]?.keys.first)
    XCTAssertEqual(lintResults.checkViolationsBySeverity[.info]?.keys.first?.id, "1")

    lintResults = try Lint.runCustomScript(
      check: .init(id: "1", hint: "hint #1", severity: .info),
      command: #"""
        echo 'Executed custom check with 100 files.\nNo issues found.' && exit 0
        """#
    )

    XCTAssertNoDifference(lintResults.allExecutedChecks.map(\.id), ["1"])
    XCTAssertEqual(lintResults.allFoundViolations.count, 0)
    XCTAssertNoDifference(lintResults.allFoundViolations.map(\.matchedString), [])
    XCTAssertNil(lintResults.checkViolationsBySeverity[.error]?.keys.first)
    XCTAssertEqual(lintResults.checkViolationsBySeverity[.info]?.keys.first?.id, "1")
  }

  func testValidateParameterCombinations() {
    XCTAssertNoDifference(testLogger.loggedMessages, [])

    Lint.validateParameterCombinations(
      check: .init(id: "1", hint: "hint #1"),
      autoCorrectReplacement: nil,
      autoCorrectExamples: [.init(before: "abc", after: "cba")],
      violateIfNoMatchesFound: false
    )

    XCTAssertNoDifference(
      testLogger.loggedMessages,
      ["[warning] `autoCorrectExamples` provided for check 1 without specifying an `autoCorrectReplacement`."]
    )

    // TODO: [cg_2021-09-05] Swift / XCTest doesn't have a way to test for functions returning `Never`
    //    Lint.validateParameterCombinations(
    //      check: .init(id: "2", hint: "hint #2"),
    //      autoCorrectReplacement: "$3$2$1",
    //      autoCorrectExamples: [.init(before: "abc", after: "cba")],
    //      violateIfNoMatchesFound: true
    //    )
    //
    //
    //    XCTAssertEqual(
    //      testLogger.loggedMessages.last,
    //      "Incompatible options specified for check 2: `autoCorrectReplacement` and `violateIfNoMatchesFound` can't be used together."
    //    )
  }

  func testCheckFileContents() {
    // TODO: [cg_2021-09-05] not yet implemented
  }

  func testCheckFilePaths() {
    // TODO: [cg_2021-09-05] not yet implemented
  }
}
