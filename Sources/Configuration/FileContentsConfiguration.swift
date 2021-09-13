import Foundation
import Core
import BetterCodable

/// The `FileContents` check configuration type.
public struct FileContentsConfiguration: CheckConfiguration, Codable {
  /// A unique identifier for the check to show on violations. Required.
  public let id: String

  /// A hint that should be shown on violations of this check. Should explain what's wrong and guide on fixing the issue. Required.
  public let hint: String

  /// The severity level of this check. One of `.info`, `.warning` or `.error`. Defaults to `.error`.
  @DefaultCodable<Severity.DefaultToError>
  public var severity: Severity

  /// The regular expression to use to find violations. Required.
  public let regex: Regex

  /// A list of strings that are expected to match the provided `regex`. Optional.
  ///
  /// If any of the provided examples doesn't match, linting will fail early to ensure the provided `regex` works as expected. The check itself will not be run.
  /// This can be considered a 'unit test' for the regex. It's recommended to provide at least one matching example & one non-matching example.
  @DefaultEmptyArray
  public var matchingExamples: [String]

  /// A list of strings that are expected to **not** to match the provided `regex`. Optional.
  ///
  /// If any of the provided examples matches, linting will fail early to ensure the provided `regex` works as expected. The check itself will not be run.
  /// This can be considered a 'unit test' for the regex. It's recommended to provide at least one matching example & one non-matching example.
  @DefaultEmptyArray
  public var nonMatchingExamples: [String]

  /// A list of path-matching regexes to restrict this check to files in the matching paths only ("allow-listing"). Optional.
  ///
  /// When combined with `excludeFilters`, the exclude paths take precedence over the include paths – in other words: 'exclude always wins'.
  @DefaultCodable<Regex.DefaultToMatchAllArray>
  public var includeFilters: [Regex]

  /// A list of path-matching regexes to skip this check on for files with matching paths ("deny-listing"). Optional.
  ///
  /// When combined with `includeFilters`, the exclude paths take precedence over the include paths – in other words: 'exclude always wins'
  @DefaultEmptyArray
  public var excludeFilters: [Regex]

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
  @DefaultEmptyArray
  public var autoCorrectExamples: [AutoCorrection]

  /// If set to `true`, a check will be re-run if there was at least one auto-correction applied on the last run. Optional.
  ///
  /// This can be useful for auto-correcting issues that can scale or repeat.
  /// For example, to ensure long numbers are separated by an underscore, you could write the regex `(\d+)(\d{3})`
  /// and specify the replacement `$1_$2$3`. By default, the number `123456789` would be transformed to `123456_789`.
  /// With this option set to `true`, the check would be re-executed after the first run (because there was a correction) and the result would be `123_456_789`.
  @DefaultFalse
  public var repeatIfAutoCorrected: Bool
}
