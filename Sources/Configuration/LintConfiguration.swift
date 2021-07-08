import Foundation
import Core

/// The configuration file type.
public struct LintConfiguration: Codable {
  enum CodingKeys: String, CodingKey {
    case fileContents = "CheckFileContents"
    case filePaths = "CheckFilePaths"
    case customScripts = "CustomScripts"
  }

  /// The list of `FileContents` checks.
  public let fileContents: [FileContentsConfiguration]

  /// The list of `FilePaths` checks.
  public let filePaths: [FilePathsConfiguration]

  /// The list of `CustomScripts` checks.
  public let customScripts: [CustomScriptsConfiguration]
}

/// The `FileContents` check configuration type.
public struct FileContentsConfiguration: Codable {
  /// A unique identifier for the check to show on violations. Required.
  public let id: String

  /// A hint that should be shown on violations of this check. Should explain what's wrong and guide on fixing the issue. Required.
  public let hint: String

  /// The severity level of this check. One of `.info`, `.warning` or `.error`. Defaults to `.error`.
  public var severity: Severity = .error

  /// The regular expression to use to find violations. Required.
  public let regex: String

  /// A list of strings that are expected to match the provided `regex`. Optional.
  ///
  /// If any of the provided examples doesn't match, linting will fail early to ensure the provided `regex` works as expected. The check itself will not be run.
  /// This can be considered a 'unit test' for the regex. It's recommended to provide at least one matching example & one non-matching example.
  public let matchingExamples: [String]?

  /// A list of strings that are expected to **not** to match the provided `regex`. Optional.
  ///
  /// If any of the provided examples matches, linting will fail early to ensure the provided `regex` works as expected. The check itself will not be run.
  /// This can be considered a 'unit test' for the regex. It's recommended to provide at least one matching example & one non-matching example.
  public let nonMatchingExamples: [String]?

  /// A list of path-matching regexes to restrict this check to files in the matching paths only ("allow-listing"). Optional.
  ///
  /// When combined with `excludeFilters`, the exclude paths take precedence over the include paths – in other words: 'exclude always wins'.
  public let includeFilters: [Regex]?

  /// A list of path-matching regexes to skip this check on for files with matching paths ("deny-listing"). Optional.
  ///
  /// When combined with `includeFilters`, the exclude paths take precedence over the include paths – in other words: 'exclude always wins'
  public let excludeFilters: [Regex]?

  /// A regex replacement template with `$1`-kind of references to capture groups in the regex. Optional.
  ///
  /// See `NSRegularExpression` documentation for examples and more details (e.g. in the 'Template Matching Format' section):
  /// https://developer.apple.com/documentation/foundation/nsregularexpression
  public let autoCorrectReplacement: String?

  /// A dictionary consisting of the keys `before` and `after` to specify how you would expect a given string to be changed. Optional.
  ///
  /// Use this to validate that the provided `regex` and the `autoCorrectReplacement` together act as expected.
  /// If any of the provided `before` doesn't get transformed to the `after`, linting will fail early and the check itself will not be run.
  ///
  /// This can be considered a 'unit test' for the auto-correction. It's recommended to provide at least one pair if you specify use `autoCorrectReplacement`.
  public let autoCorrectExamples: [AutoCorrection]?

  /// If set to `true`, a check will be re-run if there was at least one auto-correction applied on the last run. Optional.
  ///
  /// This can be useful for auto-correcting issues that can scale or repeat.
  /// For example, to ensure long numbers are separated by an underscore, you could write the regex `(\d+)(\d{3})`
  /// and specify the replacement `$1_$2$3`. By default, the number `123456789` would be transformed to `123456_789`.
  /// With this option set to `true`, the check would be re-executed after the first run (because there was a correction) and the result would be `123_456_789`.
  public let repeatIfAutoCorrected: Bool?
}

/// The `FilePaths` check configuration type.
public struct FilePathsConfiguration: Codable {
  /// A unique identifier for the check to show on violations.
  public let id: String

  /// A hint that should be shown on violations of this check. Should explain what's wrong and guide on fixing the issue.
  public let hint: String

  /// The severity level of this check. One of `.info`, `.warning` or `.error`. Defaults to `.error`.
  public var severity: Severity = .error

  /// The regular expression to use to find violations. Required.
  public let regex: String

  /// A list of strings that are expected to match the provided `regex`. Optional.
  ///
  /// If any of the provided examples doesn't match, linting will fail early to ensure the provided `regex` works as expected. The check itself will not be run.
  /// This can be considered a 'unit test' for the regex. It's recommended to provide at least one matching example & one non-matching example.
  public let matchingExamples: [String]?

  /// A list of strings that are expected to **not** to match the provided `regex`. Optional.
  ///
  /// If any of the provided examples matches, linting will fail early to ensure the provided `regex` works as expected. The check itself will not be run.
  /// This can be considered a 'unit test' for the regex. It's recommended to provide at least one matching example & one non-matching example.
  public let nonMatchingExamples: [String]?

  /// A list of path-matching regexes to restrict this check to files in the matching paths only ("allow-listing"). Optional.
  ///
  /// When combined with `excludeFilters`, the exclude paths take precedence over the include paths – in other words: 'exclude always wins'.
  public let includeFilters: [Regex]?

  /// A list of path-matching regexes to skip this check on for files with matching paths ("deny-listing"). Optional.
  ///
  /// When combined with `includeFilters`, the exclude paths take precedence over the include paths – in other words: 'exclude always wins'
  public let excludeFilters: [Regex]?

  /// A regex replacement template with `$1`-kind of references to capture groups in the regex. Optional.
  ///
  /// See `NSRegularExpression` documentation for examples and more details (e.g. in the 'Template Matching Format' section):
  /// https://developer.apple.com/documentation/foundation/nsregularexpression
  ///
  /// Use this to automatically move violating files from their current paht to the expected path.
  public let autoCorrectReplacement: String?

  /// A dictionary consisting of the keys `before` and `after` to specify how you would expect a given path to be changed. Optional.
  ///
  /// Use this to validate that the provided `regex` and the `autoCorrectReplacement` together act as expected.
  /// If any of the provided `before` doesn't get transformed to the `after`, linting will fail early and the check itself will not be run.
  ///
  /// This can be considered a 'unit test' for the auto-correction. It's recommended to provide at least one pair if you specify use `autoCorrectReplacement`.
  public let autoCorrectExamples: [AutoCorrection]?

  /// If set to `true`, a violation will be reported if **no** matches are found. By default (or if set to `false`), a check violates on every matching file path.
  public let violateIfNoMatchesFound: Bool?
}

/// The `CustomScripts` check configuration type.
public struct CustomScriptsConfiguration: Codable {
  /// The name of the custom script.
  public let name: String

  /// The severity level of this check. One of `.info`, `.warning` or `.error`. Defaults to `.error`.
  public var severity: Severity = .error

  /// The custom command line command to execute.
  /// If the output conforms to the ``LintResults`` structure formatted as JSON, then the results will be merged.
  /// Otherwise AnyLint will violate for any non-zero exit code with the last printed line.
  public let command: String
}
