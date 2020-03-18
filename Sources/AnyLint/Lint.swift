import Foundation
import Utility

/// The linter type providing APIs for checking anything using regular expressions.
public enum Lint {
    /// Checks the contents of files.
    ///
    /// - Parameters:
    ///   - checkInfo: The info object providing some general information on the lint check.
    ///   - regex: The regex to use for matching the contents of files. By defaults points to the start of the regex, unless you provide the named group 'pointer'.
    ///   - includeFilters: An array of regexes defining which files should be incuded in the check. Will check all files matching any of the given regexes.
    ///   - excludeFilters: An array of regexes defining which files should be excluded from the check. Will ignore all files matching any of the given regexes. Takes precedence over includes.
    ///   - autoCorrectReplacement: A replacement string which can reference any capture groups in the `regex` to use for autocorrection.
    ///   - matchingExamples: An array of example contents where the `regex` is expected to trigger. Optionally, the expected pointer position can be marked with ↘.
    ///   - nonMatchingExamples: An array of example contents where the `regex` is expected not to trigger.
    public static func checkFileContents(
        checkInfo: CheckInfo,
        regex: Regex,
        includeFilters: [Regex] = [#".*"#],
        excludeFilters: [Regex] = [],
        autoCorrectReplacement: String? = nil,
        matchingExamples: [String] = [],
        nonMatchingExamples: [String] = []
    ) {
        validate(regex: regex, matchesForEach: matchingExamples, checkInfo: checkInfo)
        validate(regex: regex, doesNotMatchAny: nonMatchingExamples, checkInfo: checkInfo)

        let filePathsToCheck: [String] = FilesSearch.allFiles(
            within: fileManager.currentDirectoryPath,
            includeFilters: includeFilters,
            excludeFilters: excludeFilters
        )

        let violations = FileContentsChecker(checkInfo: checkInfo, regex: regex, filePathsToCheck: filePathsToCheck).performCheck()

        violations.forEach { $0.logMessage() }
        Statistics.shared.found(violations: violations, in: checkInfo)
    }

    /// Checks the names of files.
    ///
    /// - Parameters:
    ///   - checkInfo: The info object providing some general information on the lint check.
    ///   - regex: The regex to use for matching the paths of files. By defaults points to the start of the regex, unless you provide the named group 'pointer'.
    ///   - includeFilters: Defines which files should be incuded in check. Checks all files matching any of the given regexes.
    ///   - excludeFilters: Defines which files should be excluded from check. Ignores all files matching any of the given regexes. Takes precedence over includes.
    ///   - autoCorrectReplacement: A replacement string which can reference any capture groups in the `regex` to use for autocorrection.
    ///   - matchingExamples: An array of example paths where the `regex` is expected to trigger. Optionally, the expected pointer position can be marked with ↘.
    ///   - nonMatchingExamples: An array of example paths where the `regex` is expected not to trigger.
    ///   - violateIfNoMatchesFound: Inverts the violation logic to report a single violation if no matches are found instead of reporting a violation for each match.
    public static func checkFilePaths(
        checkInfo: CheckInfo,
        regex: Regex,
        includeFilters: [Regex] = [#".*"#],
        excludeFilters: [Regex] = [],
        autoCorrectReplacement: String? = nil,
        matchingExamples: [String] = [],
        nonMatchingExamples: [String] = [],
        violateIfNoMatchesFound: Bool = false
    ) {
        validate(regex: regex, matchesForEach: matchingExamples, checkInfo: checkInfo)
        validate(regex: regex, doesNotMatchAny: nonMatchingExamples, checkInfo: checkInfo)

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

        violations.forEach { $0.logMessage() }
        Statistics.shared.found(violations: violations, in: checkInfo)
    }

    /// Run custom logic as checks.
    ///
    /// - Parameters:
    ///   - checkInfo: The info object providing some general information on the lint check.
    ///   - customClosure: The custom logic to run which produces an array of `Violation` objects for any violations.
    public static func customCheck(checkInfo: CheckInfo, customClosure: () -> [Violation]) {
        let violations = customClosure()

        violations.forEach { $0.logMessage() }
        Statistics.shared.found(violations: violations, in: checkInfo)
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
}
