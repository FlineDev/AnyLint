import Foundation
import Core
import OrderedCollections
import ShellOut
import Reporting

/// The linter type providing APIs for checking anything using regular expressions.
public enum Lint {
  /// Checks the contents of files.
  ///
  /// - Parameters:
  ///   - check: The info object providing some general information on the lint check.
  ///   - regex: The regex to use for matching the contents of files. By defaults points to the start of the regex, unless you provide the named group 'pointer'.
  ///   - matchingExamples: An array of example contents where the `regex` is expected to trigger. Optionally, the expected pointer position can be marked with ↘.
  ///   - nonMatchingExamples: An array of example contents where the `regex` is expected not to trigger.
  ///   - includeFilters: An array of regexes defining which files should be incuded in the check. Will check all files matching any of the given regexes.
  ///   - excludeFilters: An array of regexes defining which files should be excluded from the check. Will ignore all files matching any of the given regexes. Takes precedence over includes.
  ///   - autoCorrectReplacement: A replacement string which can reference any capture groups in the `regex` to use for autocorrection.
  ///   - autoCorrectExamples: An array of example structs with a `before` and an `after` String object to check if autocorrection works properly.
  ///   - repeatIfAutoCorrected: Repeat check if at least one auto-correction was applied in last run. Defaults to `false`.
  public static func checkFileContents(
    check: Check,
    regex: Regex,
    matchingExamples: [String] = [],
    nonMatchingExamples: [String] = [],
    includeFilters: [Regex] = [try! Regex(#".*"#)],
    excludeFilters: [Regex] = [],
    autoCorrectReplacement: String? = nil,
    autoCorrectExamples: [AutoCorrection] = [],
    repeatIfAutoCorrected: Bool = false
  ) throws -> [Violation] {
    validate(regex: regex, matchesForEach: matchingExamples, check: check)
    validate(regex: regex, doesNotMatchAny: nonMatchingExamples, check: check)

    validateParameterCombinations(
      check: check,
      autoCorrectReplacement: autoCorrectReplacement,
      autoCorrectExamples: autoCorrectExamples,
      violateIfNoMatchesFound: nil
    )

    if let autoCorrectReplacement = autoCorrectReplacement {
      validateAutocorrectsAllExamples(
        check: check,
        examples: autoCorrectExamples,
        regex: regex,
        autocorrectReplacement: autoCorrectReplacement
      )
    }

    let filePathsToCheck: [String] = FilesSearch.shared.allFiles(
      within: FileManager.default.currentDirectoryPath,
      includeFilters: includeFilters,
      excludeFilters: excludeFilters
    )

    let violations = try FileContentsChecker(
      id: check.id,
      hint: check.hint,
      severity: check.severity,
      regex: regex,
      filePathsToCheck: filePathsToCheck,
      autoCorrectReplacement: autoCorrectReplacement,
      repeatIfAutoCorrected: repeatIfAutoCorrected
    )
    .performCheck()

    return violations
  }

  /// Checks the names of files.
  ///
  /// - Parameters:
  ///   - check: The info object providing some general information on the lint check.
  ///   - regex: The regex to use for matching the paths of files. By defaults points to the start of the regex, unless you provide the named group 'pointer'.
  ///   - matchingExamples: An array of example paths where the `regex` is expected to trigger. Optionally, the expected pointer position can be marked with ↘.
  ///   - nonMatchingExamples: An array of example paths where the `regex` is expected not to trigger.
  ///   - includeFilters: Defines which files should be incuded in check. Checks all files matching any of the given regexes.
  ///   - excludeFilters: Defines which files should be excluded from check. Ignores all files matching any of the given regexes. Takes precedence over includes.
  ///   - autoCorrectReplacement: A replacement string which can reference any capture groups in the `regex` to use for autocorrection.
  ///   - autoCorrectExamples: An array of example structs with a `before` and an `after` String object to check if autocorrection works properly.
  ///   - violateIfNoMatchesFound: Inverts the violation logic to report a single violation if no matches are found instead of reporting a violation for each match.
  public static func checkFilePaths(
    check: Check,
    regex: Regex,
    matchingExamples: [String] = [],
    nonMatchingExamples: [String] = [],
    includeFilters: [Regex] = [try! Regex(#".*"#)],
    excludeFilters: [Regex] = [],
    autoCorrectReplacement: String? = nil,
    autoCorrectExamples: [AutoCorrection] = [],
    violateIfNoMatchesFound: Bool = false
  ) throws -> [Violation] {
    validate(regex: regex, matchesForEach: matchingExamples, check: check)
    validate(regex: regex, doesNotMatchAny: nonMatchingExamples, check: check)
    validateParameterCombinations(
      check: check,
      autoCorrectReplacement: autoCorrectReplacement,
      autoCorrectExamples: autoCorrectExamples,
      violateIfNoMatchesFound: violateIfNoMatchesFound
    )

    if let autoCorrectReplacement = autoCorrectReplacement {
      validateAutocorrectsAllExamples(
        check: check,
        examples: autoCorrectExamples,
        regex: regex,
        autocorrectReplacement: autoCorrectReplacement
      )
    }

    let filePathsToCheck: [String] = FilesSearch.shared.allFiles(
      within: FileManager.default.currentDirectoryPath,
      includeFilters: includeFilters,
      excludeFilters: excludeFilters
    )

    let violations = try FilePathsChecker(
      id: check.id,
      hint: check.hint,
      severity: check.severity,
      regex: regex,
      filePathsToCheck: filePathsToCheck,
      autoCorrectReplacement: autoCorrectReplacement,
      violateIfNoMatchesFound: violateIfNoMatchesFound
    )
    .performCheck()

    return violations
  }

  /// Run custom scripts as checks.
  ///
  /// - Returns: If the command produces an output in the ``LintResults`` JSON format, will forward them.
  ///            If the output iis an array of ``Violation`` instances, they will be wrapped in a ``LintResults`` object.
  ///            Else, it will report exactly one violation if the command has a non-zero exit code with the last line(s) of output.
  public static func runCustomScript(check: Check, command: String) throws -> LintResults {
    let tempScriptFileUrl = URL(fileURLWithPath: "_\(check.id).tempscript")
    try command.write(to: tempScriptFileUrl, atomically: true, encoding: .utf8)
    try shellOut(to: "chmod", arguments: ["+x", tempScriptFileUrl.path])

    do {
      let output = try shellOut(to: "/bin/bash", arguments: [tempScriptFileUrl.path])

      // clean up temporary script file after successful execution
      try FileManager.default.removeItem(at: tempScriptFileUrl)

      if let jsonString = output.lintResultsJsonString,
        let jsonData = jsonString.data(using: .utf8),
        let lintResults: LintResults = try? JSONDecoder.iso.decode(LintResults.self, from: jsonData)
      {
        return lintResults
      }
      else if let jsonString = output.violationsArrayJsonString,
        let jsonData = jsonString.data(using: .utf8),
        let violations: [Violation] = try? JSONDecoder.iso.decode([Violation].self, from: jsonData)
      {
        return [check.severity: [check: violations]]
      }
      else {
        // if the command fails, a ShellOutError will be thrown – here, none is thrown, so no violations
        return [check.severity: [check: []]]
      }
    }
    catch {
      // clean up temporary script file after failed execution
      try? FileManager.default.removeItem(at: tempScriptFileUrl)

      if let shellOutError = error as? ShellOutError, shellOutError.terminationStatus != 0 {
        return [
          check.severity: [
            check: [
              Violation(message: shellOutError.output.components(separatedBy: .newlines).last)
            ]
          ]
        ]
      }

      throw error
    }
  }

  static func validate(regex: Regex, matchesForEach matchingExamples: [String], check: Check) {
    for example in matchingExamples {
      if !regex.matches(example) {
        log.message(
          "Couldn't find a match for regex \(regex) in check '\(check.id)' within matching example:\n\(example)",
          level: .error
        )
        log.exit(fail: true)
      }
    }
  }

  static func validate(regex: Regex, doesNotMatchAny nonMatchingExamples: [String], check: Check) {
    for example in nonMatchingExamples {
      if regex.matches(example) {
        log.message(
          "Unexpectedly found a match for regex \(regex) in check '\(check.id)' within non-matching example:\n\(example)",
          level: .error
        )
        log.exit(fail: true)
      }
    }
  }

  static func validateAutocorrectsAllExamples(
    check: Check,
    examples: [AutoCorrection],
    regex: Regex,
    autocorrectReplacement: String
  ) {
    for autocorrect in examples {
      let autocorrected = regex.replaceAllCaptures(in: autocorrect.before, with: autocorrectReplacement)
      if autocorrected != autocorrect.after {
        log.message(
          """
          Autocorrecting example for \(check.id) did not result in expected output.
          Before:   '\(autocorrect.before.showWhitespacesAndNewlines())'
          After:    '\(autocorrected.showWhitespacesAndNewlines())'
          Expected: '\(autocorrect.after.showWhitespacesAndNewlines())'
          """,
          level: .error
        )
        log.exit(fail: true)
      }
    }
  }

  static func validateParameterCombinations(
    check: Check,
    autoCorrectReplacement: String?,
    autoCorrectExamples: [AutoCorrection],
    violateIfNoMatchesFound: Bool?
  ) {
    if autoCorrectExamples.isFilled && autoCorrectReplacement == nil {
      log.message(
        "`autoCorrectExamples` provided for check \(check.id) without specifying an `autoCorrectReplacement`.",
        level: .warning
      )
    }

    guard autoCorrectReplacement == nil || violateIfNoMatchesFound != true else {
      log.message(
        "Incompatible options specified for check \(check.id): `autoCorrectReplacement` and `violateIfNoMatchesFound` can't be used together.",
        level: .error
      )
      log.exit(fail: true)
    }
  }
}

fileprivate extension String {
  var lintResultsJsonString: String? {
    try! Regex(
      #"\{.*(?:\"error\"\s*:|\"warning\"\s*:|\"info\"\s*:).*\}"#,
      options: .dotMatchesLineSeparators
    )
    .firstMatch(in: self)?
    .string
  }

  var violationsArrayJsonString: String? {
    try! Regex(
      #"\[(?:\s*\{.*\}\s*,)*(?:\s*\{.*\}\s*)?\]"#,
      options: .dotMatchesLineSeparators
    )
    .firstMatch(in: self)?
    .string
  }
}
