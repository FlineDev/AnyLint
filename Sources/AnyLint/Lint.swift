import Foundation
import HandySwift
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
        includeFilters: [Regex] = [],
        excludeFilters: [Regex] = [],
        autoCorrectReplacement: String? = nil,
        matchingExamples: [String] = [],
        nonMatchingExamples: [String] = []
    ) {
        // TODO: [cg_2020-03-13] validate matching and non-matching examples first

        var violations: [Violation] = []
        let filePathsToCheck: [String] = FilesSearch.allFiles(
            within: fileManager.currentDirectoryPath,
            includeFilters: includeFilters,
            excludeFilters: excludeFilters
        )

        for filePath in filePathsToCheck {
            if let fileData = fileManager.contents(atPath: filePath), let fileContents = String(data: fileData, encoding: .utf8) {
                for match in regex.matches(in: fileContents) {
                    // TODO: [cg_2020-03-13] use capture group named 'pointer' if exists
                    let locationInfo = fileContents.locationInfo(of: match.range.lowerBound)

                    // TODO: [cg_2020-03-13] autocorrect if autocorrection is available
                    violations.append(
                        FileContentViolation(
                            checkInfo: checkInfo,
                            filePath: filePath,
                            lineNum: locationInfo.line,
                            charInLine: locationInfo.charInLine
                        )
                    )
                }
            } else {
                log.message("Could not read contents of file at \(filePath). Make sure it is a text file and is formatted as UTF8.", level: .warning)
            }
        }

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
        includeFilters: [Regex] = [],
        excludeFilters: [Regex] = [],
        autoCorrectReplacement: String? = nil,
        matchingExamples: [String] = [],
        nonMatchingExamples: [String] = [],
        violateIfNoMatchesFound: Bool = false
    ) {
        // TODO: [cg_2020-03-13] validate matching and non-matching examples first

        var violations: [Violation] = []
        let filePathsToCheck: [String] = FilesSearch.allFiles(
            within: fileManager.currentDirectoryPath,
            includeFilters: includeFilters,
            excludeFilters: excludeFilters
        )

        // TODO: [cg_2020-03-12] not yet implemented

        Statistics.shared.found(violations: violations, in: checkInfo)
    }

    /// Checks the last commit message.
    ///
    /// - Parameters:
    ///   - checkInfo: The info object providing some general information on the lint check.
    ///   - regex: The regex to use for matching the commit message.
    ///   - matchingExamples: An array of example messages where the `regex` is expected to trigger. Optionally, the expected pointer position can be marked with ↘.
    ///   - nonMatchingExamples: An array of example messages where the `regex` is expected not to trigger.
    public static func checkLastCommitMessage(
        checkInfo: CheckInfo,
        regex: Regex,
        matchingExamples: [String] = [],
        nonMatchingExamples: [String] = []
    ) {
        // TODO: [cg_2020-03-13] validate matching and non-matching examples first

        var violations: [Violation] = []

        // TODO: [cg_2020-03-12] not yet implemented

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
}
