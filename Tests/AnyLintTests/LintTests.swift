@testable import AnyLint
@testable import Utility
import XCTest

final class LintTests: XCTestCase {
   override func setUp() {
      log = Logger(outputType: .test)
      TestHelper.shared.reset()
   }

   func testValidateRegexMatchesForEach() {
      XCTAssertNil(TestHelper.shared.exitStatus)

      let regex: Regex = #"foo[0-9]?bar"#
      let checkInfo = CheckInfo(id: "foo_bar", hint: "do bar", severity: .warning)

      Lint.validate(
         regex: regex,
         matchesForEach: ["foo1bar", "foobar", "myfoo4barbeque"],
         checkInfo: checkInfo
      )
      XCTAssertNil(TestHelper.shared.exitStatus)

      Lint.validate(
         regex: regex,
         matchesForEach: ["foo1bar", "FooBar", "myfoo4barbeque"],
         checkInfo: checkInfo
      )
      XCTAssertEqual(TestHelper.shared.exitStatus, .failure)
   }

   func testValidateRegexDoesNotMatchAny() {
      XCTAssertNil(TestHelper.shared.exitStatus)

      let regex: Regex = #"foo[0-9]?bar"#
      let checkInfo = CheckInfo(id: "foo_bar", hint: "do bar", severity: .warning)

      Lint.validate(
         regex: regex,
         doesNotMatchAny: ["fooLbar", "FooBar", "myfoo40barbeque"],
         checkInfo: checkInfo
      )
      XCTAssertNil(TestHelper.shared.exitStatus)

      Lint.validate(
         regex: regex,
         doesNotMatchAny: ["fooLbar", "foobar", "myfoo40barbeque"],
         checkInfo: checkInfo
      )
      XCTAssertEqual(TestHelper.shared.exitStatus, .failure)
   }

   func testValidateAutocorrectsAllExamplesWithAnonymousGroups() {
      XCTAssertNil(TestHelper.shared.exitStatus)

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

      XCTAssertNil(TestHelper.shared.exitStatus)

      Lint.validateAutocorrectsAll(
         checkInfo: CheckInfo(id: "id", hint: "hint"),
         examples: [
            AutoCorrection(before: "prefix.content.suffix", after: "suffix.content.prefix"),
            AutoCorrection(before: "forums.swift.org", after: "org.swift.forums"),
         ],
         regex: anonymousCaptureRegex!,
         autocorrectReplacement: "$4$1$2$3$0"
      )

      XCTAssertEqual(TestHelper.shared.exitStatus, .failure)
   }

   func testValidateAutocorrectsAllExamplesWithNamedGroups() {
      XCTAssertNil(TestHelper.shared.exitStatus)

      let namedCaptureRegex: Regex = [
         "prefix": #"[^\.]+"#,
         "separator1": #"\."#,
         "content": #"[^\.]+"#,
         "separator2": #"\."#,
         "suffix": #"[^\.]+"#,
      ]

      Lint.validateAutocorrectsAll(
         checkInfo: CheckInfo(id: "id", hint: "hint"),
         examples: [
            AutoCorrection(before: "prefix.content.suffix", after: "suffix.content.prefix"),
            AutoCorrection(before: "forums.swift.org", after: "org.swift.forums"),
         ],
         regex: namedCaptureRegex,
         autocorrectReplacement: "$suffix$separator1$content$separator2$prefix"
      )

      XCTAssertNil(TestHelper.shared.exitStatus)

      Lint.validateAutocorrectsAll(
         checkInfo: CheckInfo(id: "id", hint: "hint"),
         examples: [
            AutoCorrection(before: "prefix.content.suffix", after: "suffix.content.prefix"),
            AutoCorrection(before: "forums.swift.org", after: "org.swift.forums"),
         ],
         regex: namedCaptureRegex,
         autocorrectReplacement: "$sfx$sep1$cnt$sep2$pref"
      )

      XCTAssertEqual(TestHelper.shared.exitStatus, .failure)
   }
}
