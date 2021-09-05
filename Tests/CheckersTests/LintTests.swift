@testable import Checkers
import XCTest
import Core
import TestSupport

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

  func testRunCustomScript() {
    // TODO: [cg_2021-09-05] not yet implemented
  }

  func testValidateParameterCombinations() {
    // TODO: [cg_2021-09-05] not yet implemented
  }

  func testCheckFileContents() {
    // TODO: [cg_2021-09-05] not yet implemented
  }

  func testCheckFilePaths() {
    // TODO: [cg_2021-09-05] not yet implemented
  }
}
