import Foundation
import HandySwift

/// The linter type providing APIs for checking anything using regular expressions.
public enum Lint {
    /// Checks the contents of files.
    ///
    /// - Parameters:
    ///   - checkInfo: The info object providing some general information on the lint check.
    ///   - regex: The regex to use for matching the contents of files. By defaults points to the start of the regex, unless you provide the named group 'pointer'.
    ///   - includedFileRegexes: An array of regexes defining which files should be incuded in the check. Will check all files matching any of the given regexes.
    ///   - excludedFileRegexes: An array of regexes defining which files should be excluded from the check. Will ignore all files matching any of the given regexes. Takes precedence over includes.
    ///   - autoCorrectReplacement: A replacement string which can reference any capture groups in the `contentRegex` to use for autocorrection.
    ///   - triggeringExamples: An array of example contents where the `contentRegex` is expected to trigger. Optionally, the expected pointer position can be marked with ↘.
    ///   - nonTriggeringExamples: An array of examples contents where the `contentRegex` is expected not to trigger.
    public static func checkFileContents(
        checkInfo: CheckInfo,
        regex: Regex,
        includedFileRegexes: [Regex],
        excludedFileRegexes: [Regex] = [],
        autoCorrectReplacement: String? = nil,
        triggeringExamples: [String] = [],
        nonTriggeringExamples: [String] = []
    ) {
        var violations: [Violation] = []

        // TODO: [cg_2020-03-12] not yet implemented

        Statistics.shared.found(violations: violations, in: checkInfo)
    }

    /// Checks the names of files.
    ///
    /// - Parameters:
    ///   - checkInfo: The info object providing some general information on the lint check.
    ///   - regex: The regex to use for matching the paths of files. By defaults points to the start of the regex, unless you provide the named group 'pointer'.
    ///   - includedFileRegexes: Defines which files should be incuded in check. Checks all files matching any of the given regexes.
    ///   - excludedFileRegexes: Defines which files should be excluded from check. Ignores all files matching any of the given regexes. Takes precedence over includes.
    ///   - autoCorrectReplacement: A replacement string which can reference any capture groups in the `contentRegex` to use for autocorrection.
    ///   - triggeringExamples: An array of example contents where the `contentRegex` is expected to trigger. Optionally, the expected pointer position can be marked with ↘.
    ///   - nonTriggeringExamples: An array of examples contents where the `contentRegex` is expected not to trigger.
    public static func checkFilePaths(
        checkInfo: CheckInfo,
        regex: Regex,
        includedFileRegexes: [Regex],
        excludedFileRegexes: [Regex] = [],
        autoCorrectReplacement: String? = nil,
        triggeringExamples: [String] = [],
        nonTriggeringExamples: [String] = []
    ) {
        var violations: [Violation] = []

        // TODO: [cg_2020-03-12] not yet implemented

        Statistics.shared.found(violations: violations, in: checkInfo)
    }

    /// Checks the last commit message.
    ///
    /// - Parameters:
    ///   - checkInfo: The info object providing some general information on the lint check.
    ///   - regex: The regex to use for matching the commit message.
    public static func checkLastCommitMessage(checkInfo: CheckInfo, regex: Regex) {
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
