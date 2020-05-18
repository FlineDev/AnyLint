import Foundation
import Utility

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
        includeFilters: [Regex] = [#".*"#],
        excludeFilters: [Regex] = [],
        autoCorrectReplacement: String? = nil,
        autoCorrectExamples: [AutoCorrection] = [],
        repeatIfAutoCorrected: Bool = false
    ) throws {
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

        guard !Options.validateOnly else {
            Statistics.shared.executedChecks.append(checkInfo)
            return
        }

        let filePathsToCheck: [String] = FilesSearch.shared.allFiles(
            within: fileManager.currentDirectoryPath,
            includeFilters: includeFilters,
            excludeFilters: excludeFilters
        )

        let violations = try FileContentsChecker(
            checkInfo: checkInfo,
            regex: regex,
            filePathsToCheck: filePathsToCheck,
            autoCorrectReplacement: autoCorrectReplacement,
            repeatIfAutoCorrected: repeatIfAutoCorrected
        ).performCheck()

        Statistics.shared.found(violations: violations, in: checkInfo)
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
        includeFilters: [Regex] = [#".*"#],
        excludeFilters: [Regex] = [],
        autoCorrectReplacement: String? = nil,
        autoCorrectExamples: [AutoCorrection] = [],
        violateIfNoMatchesFound: Bool = false
    ) throws {
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

        guard !Options.validateOnly else {
            Statistics.shared.executedChecks.append(checkInfo)
            return
        }

        let filePathsToCheck: [String] = FilesSearch.shared.allFiles(
            within: fileManager.currentDirectoryPath,
            includeFilters: includeFilters,
            excludeFilters: excludeFilters
        )

        let violations = try FilePathsChecker(
            checkInfo: checkInfo,
            regex: regex,
            filePathsToCheck: filePathsToCheck,
            autoCorrectReplacement: autoCorrectReplacement,
            violateIfNoMatchesFound: violateIfNoMatchesFound
        ).performCheck()

        Statistics.shared.found(violations: violations, in: checkInfo)
    }

    /// Run custom logic as checks.
    ///
    /// - Parameters:
    ///   - checkInfo: The info object providing some general information on the lint check.
    ///   - customClosure: The custom logic to run which produces an array of `Violation` objects for any violations.
    public static func customCheck(checkInfo: CheckInfo, customClosure: (CheckInfo) -> [Violation]) {
        guard !Options.validateOnly else {
            Statistics.shared.executedChecks.append(checkInfo)
            return
        }

        Statistics.shared.found(violations: customClosure(checkInfo), in: checkInfo)
    }

    /// Logs the summary of all detected violations and exits successfully on no violations or with a failure, if any violations.
    public static func logSummaryAndExit(arguments: [String] = [], afterPerformingChecks checksToPerform: () throws -> Void = {}) throws {
        let failOnWarnings = arguments.contains(Constants.strictArgument)
        let targetIsXcode = arguments.contains(Logger.OutputType.xcode.rawValue)

        if targetIsXcode {
            log = Logger(outputType: .xcode)
        }

        log.logDebugLevel = arguments.contains(Constants.debugArgument)
        Options.validateOnly = arguments.contains(Constants.validateArgument)

        try checksToPerform()

        guard !Options.validateOnly else {
            Statistics.shared.logValidationSummary()
            log.exit(status: .success)
            return // only reachable in unit tests
        }

        Statistics.shared.logCheckSummary()

        if Statistics.shared.violations(severity: .error, excludeAutocorrected: targetIsXcode).isFilled {
            log.exit(status: .failure)
        } else if failOnWarnings && Statistics.shared.violations(severity: .warning, excludeAutocorrected: targetIsXcode).isFilled {
            log.exit(status: .failure)
        } else {
            log.exit(status: .success)
        }
    }

    static func validate(regex: Regex, matchesForEach matchingExamples: [String], checkInfo: CheckInfo) {
        if matchingExamples.isFilled {
            log.message("Validating 'matchingExamples' for \(checkInfo) ...", level: .debug)
        }

        for example in matchingExamples {
            if !regex.matches(example) {
                log.message(
                    "Couldn't find a match for regex \(regex) in check '\(checkInfo.id)' within matching example:\n\(example)",
                    level: .error
                )
                log.exit(status: .failure)
            }
        }
    }

    static func validate(regex: Regex, doesNotMatchAny nonMatchingExamples: [String], checkInfo: CheckInfo) {
        if nonMatchingExamples.isFilled {
            log.message("Validating 'nonMatchingExamples' for \(checkInfo) ...", level: .debug)
        }

        for example in nonMatchingExamples {
            if regex.matches(example) {
                log.message(
                    "Unexpectedly found a match for regex \(regex) in check '\(checkInfo.id)' within non-matching example:\n\(example)",
                    level: .error
                )
                log.exit(status: .failure)
            }
        }
    }

    static func validateAutocorrectsAll(checkInfo: CheckInfo, examples: [AutoCorrection], regex: Regex, autocorrectReplacement: String) {
        if examples.isFilled {
            log.message("Validating 'autoCorrectExamples' for \(checkInfo) ...", level: .debug)
        }

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
                log.exit(status: .failure)
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
            log.exit(status: .failure)
            return // only reachable in unit tests
        }
    }
}
