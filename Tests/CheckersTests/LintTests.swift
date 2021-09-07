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
    let checkInfo = CheckInfo(id: "foo_bar", hint: "do bar", severity: .warning)

    Lint.validate(
      regex: regex,
      matchesForEach: ["foo1bar", "foobar", "myfoo4barbeque"],
      checkInfo: checkInfo
    )
    XCTAssertNil(testLogger.exitStatusCode)

    // TODO: [cg_2021-09-05] Swift / XCTest doesn't have a way to test for functions returning `Never`
    //    Lint.validate(
    //      regex: regex,
    //      matchesForEach: ["foo1bar", "FooBar", "myfoo4barbeque"],
    //      checkInfo: checkInfo
    //    )
    //    XCTAssertEqual(testLogger.exitStatusCode, EXIT_FAILURE)
  }

  func testValidateRegexDoesNotMatchAny() {
    XCTAssertNil(testLogger.exitStatusCode)

    let regex = try! Regex(#"foo[0-9]?bar"#)
    let checkInfo = CheckInfo(id: "foo_bar", hint: "do bar", severity: .warning)

    Lint.validate(
      regex: regex,
      doesNotMatchAny: ["fooLbar", "FooBar", "myfoo40barbeque"],
      checkInfo: checkInfo
    )
    XCTAssertNil(testLogger.exitStatusCode)

    // TODO: [cg_2021-09-05] Swift / XCTest doesn't have a way to test for functions returning `Never`
    //    Lint.validate(
    //      regex: regex,
    //      doesNotMatchAny: ["fooLbar", "foobar", "myfoo40barbeque"],
    //      checkInfo: checkInfo
    //    )
    //    XCTAssertEqual(testLogger.exitStatusCode, EXIT_FAILURE)
  }

  func testValidateAutocorrectsAllExamplesWithAnonymousGroups() {
    XCTAssertNil(testLogger.exitStatusCode)

    let anonymousCaptureRegex = try? Regex(#"([^\.]+)(\.)([^\.]+)(\.)([^\.]+)"#)

    Lint.validateAutocorrectsAll(
      checkInfo: CheckInfo(id: "id", hint: "hint"),
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
    //      checkInfo: CheckInfo(id: "id", hint: "hint"),
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
      checkInfo: CheckInfo(id: "id", hint: "hint"),
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
    //      checkInfo: CheckInfo(id: "id", hint: "hint"),
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
      checkInfo: .init(id: "1", hint: "hint #1"),
      command: """
        if which echo > /dev/null; then
          echo 'Executed custom checks with following result:
          {
            "warning": {
              "A@warning: hint for A": [
                {},
                { "matchedString": "A" },
                {
                  "matchedString": "AAA",
                  "location": { "filePath": "/some/path", "row": 5 },
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

        """
    )

    XCTAssertNoDifference(lintResults.allExecutedChecks.map(\.id), ["A", "B"])
    XCTAssertEqual(lintResults.allFoundViolations.count, 3)
    XCTAssertNoDifference(lintResults.allFoundViolations.map(\.matchedString), ["A", "AAA"])
    XCTAssertEqual(lintResults.allFoundViolations.dropFirst().first?.location?.filePath, "/some/path")
    XCTAssertEqual(lintResults.allFoundViolations.dropFirst().first?.location?.row, 5)
    XCTAssertEqual(lintResults.allFoundViolations.dropFirst().first?.appliedAutoCorrection?.after, "A")
    XCTAssertNil(lintResults[.error]?.keys.first)
    XCTAssertEqual(lintResults[.info]?.keys.first?.id, "B")
  }

  func testValidateParameterCombinations() {
    XCTAssertNoDifference(testLogger.loggedMessages, [])

    Lint.validateParameterCombinations(
      checkInfo: .init(id: "1", hint: "hint #1"),
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
    //      checkInfo: .init(id: "2", hint: "hint #2"),
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
