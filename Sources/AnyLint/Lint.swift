import Foundation
import Utility

/// The linter type providing APIs for checking anything using regular expressions.
public enum Lint {
    /// Example String tuples with a `before` and `after` autocorrection matching String.
    public typealias AutoCorrectExample = (before: String, after: String)

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
    ///   - autoCorrectExamples: An array of example tuples with a `before` and an `after` String object to check if autocorrection works properly.
    public static func checkFileContents(
        checkInfo: CheckInfo,
        regex: Regex,
        matchingExamples: [String] = [],
        nonMatchingExamples: [String] = [],
        includeFilters: [Regex] = [#".*"#],
        excludeFilters: [Regex] = [],
        autoCorrectReplacement: String? = nil,
        autoCorrectExamples: [AutoCorrectExample] = []
    ) {
        validate(regex: regex, matchesForEach: matchingExamples, checkInfo: checkInfo)
        validate(regex: regex, doesNotMatchAny: nonMatchingExamples, checkInfo: checkInfo)

        if let autoCorrectReplacement = autoCorrectReplacement {
            validateAutocorrectsAll(examples: autoCorrectExamples, regex: regex, autocorrectReplacement: autoCorrectReplacement)
        }

        let filePathsToCheck: [String] = FilesSearch.allFiles(
            within: fileManager.currentDirectoryPath,
            includeFilters: includeFilters,
            excludeFilters: excludeFilters
        )

        let violations = FileContentsChecker(checkInfo: checkInfo, regex: regex, filePathsToCheck: filePathsToCheck).performCheck()
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
    ///   - autoCorrectExamples: An array of example tuples with a `before` and an `after` String object to check if autocorrection works properly.
    ///   - violateIfNoMatchesFound: Inverts the violation logic to report a single violation if no matches are found instead of reporting a violation for each match.
    public static func checkFilePaths(
        checkInfo: CheckInfo,
        regex: Regex,
        matchingExamples: [String] = [],
        nonMatchingExamples: [String] = [],
        includeFilters: [Regex] = [#".*"#],
        excludeFilters: [Regex] = [],
        autoCorrectReplacement: String? = nil,
        autoCorrectExamples: [AutoCorrectExample] = [],
        violateIfNoMatchesFound: Bool = false
    ) {
        validate(regex: regex, matchesForEach: matchingExamples, checkInfo: checkInfo)
        validate(regex: regex, doesNotMatchAny: nonMatchingExamples, checkInfo: checkInfo)

        if let autoCorrectReplacement = autoCorrectReplacement {
            validateAutocorrectsAll(examples: autoCorrectExamples, regex: regex, autocorrectReplacement: autoCorrectReplacement)
        }

        let filePathsToCheck: [String] = FilesSearch.allFiles(
            within: fileManager.currentDirectoryPath,
            includeFilters: includeFilters,
            excludeFilters: excludeFilters
        )

        let violations = FilePathsChecker(
            checkInfo: checkInfo,
            regex: regex,
            filePathsToCheck: filePathsToCheck,
            violateIfNoMatchesFound: violateIfNoMatchesFound
        ).performCheck()

        Statistics.shared.found(violations: violations, in: checkInfo)
    }

    /// Run custom logic as checks.
    ///
    /// - Parameters:
    ///   - checkInfo: The info object providing some general information on the lint check.
    ///   - customClosure: The custom logic to run which produces an array of `Violation` objects for any violations.
    public static func customCheck(checkInfo: CheckInfo, customClosure: () -> [Violation]) {
        Statistics.shared.found(violations: customClosure(), in: checkInfo)
    }

    /// Logs the summary of all detected violations and exits successfully on no violations or with a failure, if any violations.
    public static func logSummaryAndExit(failOnWarnings: Bool = false) {
        Statistics.shared.logSummary()

        if Statistics.shared.violationsBySeverity[.error]!.isFilled {
            log.exit(status: .failure)
        } else if failOnWarnings && Statistics.shared.violationsBySeverity[.warning]!.isFilled {
            log.exit(status: .failure)
        } else {
            log.exit(status: .success)
        }
    }

    static func validate(regex: Regex, matchesForEach matchingExamples: [String], checkInfo: CheckInfo) {
        for example in matchingExamples {
            if !regex.matches(example) {
                // TODO: [cg_2020-03-14] check position of ↘ is the matching line and char.
                log.message(
                    "Couldn't find a match for regex '\(regex)' in check '\(checkInfo.id)' within matching example:\n\(example)",
                    level: .error
                )
                log.exit(status: .failure)
            }
        }
    }

    static func validate(regex: Regex, doesNotMatchAny nonMatchingExamples: [String], checkInfo: CheckInfo) {
        for example in nonMatchingExamples {
            if regex.matches(example) {
                // TODO: [cg_2020-03-14] check position of ↘ is the matching line and char.
                log.message(
                    "Unexpectedly found a match for regex '\(regex)' in check '\(checkInfo.id)' within non-matching example:\n\(example)",
                    level: .error
                )
                log.exit(status: .failure)
            }
        }
    }

    static func validateAutocorrectsAll(examples: [AutoCorrectExample], regex: Regex, autocorrectReplacement: String) {
        for (before, after) in examples {
            let autocorrected = regex.replacingMatches(
                in: before,
                with: numerizedNamedCaptureRefs(in: autocorrectReplacement, relatedRegex: regex)
            )
            if autocorrected != after {
                log.message(
                    "Autocorrecting example '\(before)' did not result in expected output. Expected '\(after)' but got '\(autocorrected)' instead.",
                    level: .error
                )
                log.exit(status: .failure)
            }
        }
    }

    /// Numerizes references to named capture groups to work around missing named capture group replacement in `NSRegularExpression` APIs.
    static func numerizedNamedCaptureRefs(in replacementString: String, relatedRegex: Regex) -> String {
        let captureGroupNameRegex = Regex(#"\(\?\<([a-zA-Z0-9_-]+)\>[^\)]+\)"#)
        let captureGroupNames: [String] = captureGroupNameRegex.matches(in: relatedRegex.pattern).map { $0.captures[0]! }
        return captureGroupNames.enumerated().reduce(replacementString) { result, enumeratedGroupName in
            result.replacingOccurrences(of: "$\(enumeratedGroupName.element)", with: "$\(enumeratedGroupName.offset + 1)")
        }
    }
}
