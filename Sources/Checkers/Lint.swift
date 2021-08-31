import Foundation
import Core
import OrderedCollections

/// The linter type providing APIs for checking anything using regular expressions.
public enum Lint {
  /// Checks the contents of files.
  ///
  /// - Parameters:
  ///   - checkInfo: The info object providing some general information on the lint check.
  ///   - regex: The regex to use for matching the contents of files. By defaults points to the start of the regex, unless you provide the named group 'pointer'.
  ///   - matchingExamples: An array of example contents where the `regex` is expected to trigger. Optionally, the expected pointer position can be marked with ↘.
  ///   - nonMatchingExamples: An array of example contents where the `regex` is expected not to trigger.
  ///   - includeFilters: An array of regexes defining which files should be incuded in the check. Will check all files matching any of the given regexes.
  ///   - excludeFilters: An array of regexes defining which files should be excluded from the check. Will ignore all files matching any of the given regexes. Takes precedence over includes.
  ///   - autoCorrectReplacement: A replacement string which can reference any capture groups in the `regex` to use for autocorrection.
  ///   - autoCorrectExamples: An array of example structs with a `before` and an `after` String object to check if autocorrection works properly.
  ///   - repeatIfAutoCorrected: Repeat check if at least one auto-correction was applied in last run. Defaults to `false`.
  public static func checkFileContents(
    checkInfo: CheckInfo,
    regex: Regex,
    matchingExamples: [String] = [],
    nonMatchingExamples: [String] = [],
    includeFilters: [Regex] = [try! Regex(#".*"#)],
    excludeFilters: [Regex] = [],
    autoCorrectReplacement: String? = nil,
    autoCorrectExamples: [AutoCorrection] = [],
    repeatIfAutoCorrected: Bool = false
  ) throws -> [Violation] {
    validate(regex: regex, matchesForEach: matchingExamples, checkInfo: checkInfo)
    validate(regex: regex, doesNotMatchAny: nonMatchingExamples, checkInfo: checkInfo)

    validateParameterCombinations(
      checkInfo: checkInfo,
      autoCorrectReplacement: autoCorrectReplacement,
      autoCorrectExamples: autoCorrectExamples,
      violateIfNoMatchesFound: nil
    )

    if let autoCorrectReplacement = autoCorrectReplacement {
      validateAutocorrectsAll(
        checkInfo: checkInfo,
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
      id: checkInfo.id,
      hint: checkInfo.hint,
      severity: checkInfo.severity,
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
  ///   - checkInfo: The info object providing some general information on the lint check.
  ///   - regex: The regex to use for matching the paths of files. By defaults points to the start of the regex, unless you provide the named group 'pointer'.
  ///   - matchingExamples: An array of example paths where the `regex` is expected to trigger. Optionally, the expected pointer position can be marked with ↘.
  ///   - nonMatchingExamples: An array of example paths where the `regex` is expected not to trigger.
  ///   - includeFilters: Defines which files should be incuded in check. Checks all files matching any of the given regexes.
  ///   - excludeFilters: Defines which files should be excluded from check. Ignores all files matching any of the given regexes. Takes precedence over includes.
  ///   - autoCorrectReplacement: A replacement string which can reference any capture groups in the `regex` to use for autocorrection.
  ///   - autoCorrectExamples: An array of example structs with a `before` and an `after` String object to check if autocorrection works properly.
  ///   - violateIfNoMatchesFound: Inverts the violation logic to report a single violation if no matches are found instead of reporting a violation for each match.
  public static func checkFilePaths(
    checkInfo: CheckInfo,
    regex: Regex,
    matchingExamples: [String] = [],
    nonMatchingExamples: [String] = [],
    includeFilters: [Regex] = [try! Regex(#".*"#)],
    excludeFilters: [Regex] = [],
    autoCorrectReplacement: String? = nil,
    autoCorrectExamples: [AutoCorrection] = [],
    violateIfNoMatchesFound: Bool = false
  ) throws -> [Violation] {
    validate(regex: regex, matchesForEach: matchingExamples, checkInfo: checkInfo)
    validate(regex: regex, doesNotMatchAny: nonMatchingExamples, checkInfo: checkInfo)
    validateParameterCombinations(
      checkInfo: checkInfo,
      autoCorrectReplacement: autoCorrectReplacement,
      autoCorrectExamples: autoCorrectExamples,
      violateIfNoMatchesFound: violateIfNoMatchesFound
    )

    if let autoCorrectReplacement = autoCorrectReplacement {
      validateAutocorrectsAll(
        checkInfo: checkInfo,
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
      id: checkInfo.id,
      hint: checkInfo.hint,
      severity: checkInfo.severity,
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
  /// - Returns: If the command produces an output in the ``LintResults`` JSON format, will forward them. Else, it will report exactly one violation if the command has a non-zero exit code with the last line(s) of output.
  public static func runCustomScript(checkInfo: CheckInfo, command: String) throws -> [Violation] {
    fatalError()  // TODO: [cg_2021-07-09] not yet implemented
  }

  static func validate(regex: Regex, matchesForEach matchingExamples: [String], checkInfo: CheckInfo) {
    for example in matchingExamples {
      if !regex.matches(example) {
        log.message(
          "Couldn't find a match for regex \(regex) in check '\(checkInfo.id)' within matching example:\n\(example)",
          level: .error
        )
        log.exit(fail: true)
      }
    }
  }

  static func validate(regex: Regex, doesNotMatchAny nonMatchingExamples: [String], checkInfo: CheckInfo) {
    for example in nonMatchingExamples {
      if regex.matches(example) {
        log.message(
          "Unexpectedly found a match for regex \(regex) in check '\(checkInfo.id)' within non-matching example:\n\(example)",
          level: .error
        )
        log.exit(fail: true)
      }
    }
  }

  static func validateAutocorrectsAll(
    checkInfo: CheckInfo,
    examples: [AutoCorrection],
    regex: Regex,
    autocorrectReplacement: String
  ) {
    for autocorrect in examples {
      let autocorrected = regex.replaceAllCaptures(in: autocorrect.before, with: autocorrectReplacement)
      if autocorrected != autocorrect.after {
        log.message(
          """
          Autocorrecting example for \(checkInfo.id) did not result in expected output.
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
    checkInfo: CheckInfo,
    autoCorrectReplacement: String?,
    autoCorrectExamples: [AutoCorrection],
    violateIfNoMatchesFound: Bool?
  ) {
    if autoCorrectExamples.isFilled && autoCorrectReplacement == nil {
      log.message(
        "`autoCorrectExamples` provided for check \(checkInfo.id) without specifying an `autoCorrectReplacement`.",
        level: .warning
      )
    }

    guard autoCorrectReplacement == nil || violateIfNoMatchesFound != true else {
      log.message(
        "Incompatible options specified for check \(checkInfo.id): autoCorrectReplacement and violateIfNoMatchesFound can't be used together.",
        level: .error
      )
      log.exit(fail: true)
    }
  }
}
