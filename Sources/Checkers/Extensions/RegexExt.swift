import Foundation
import Core

extension Regex {
  /// Constants to reference across the project related to Regexes.
  enum Constants {
    /// The separator indicating that next come regex options.
    static let regexOptionsSeparator: String = #"\"#

    /// Hint that the case insensitive option should be active on a Regex.
    static let caseInsensitiveRegexOption: String = "i"

    /// Hint that the case dot matches newline option should be active on a Regex.
    static let dotMatchesNewlinesRegexOption: String = "m"
  }
}

extension Regex {
  /// Replaces all captures groups with the given capture references. References can be numbers like `$1` and capture names like `$prefix`.
  public func replaceAllCaptures(in input: String, with template: String) -> String {
    replacingMatches(in: input, with: numerizedNamedCaptureRefs(in: template))
  }

  /// Numerizes references to named capture groups to work around missing named capture group replacement in `NSRegularExpression` APIs.
  func numerizedNamedCaptureRefs(in replacementString: String) -> String {
    let captureGroupNameRegex = try! Regex(#"\(\?\<([a-zA-Z0-9_-]+)\>[^\)]+\)"#)
    let captureGroupNames: [String] = captureGroupNameRegex.matches(in: pattern).map { $0.captures[0]! }
    return captureGroupNames.enumerated()
      .reduce(replacementString) { result, enumeratedGroupName in
        result.replacingOccurrences(of: "$\(enumeratedGroupName.element)", with: "$\(enumeratedGroupName.offset + 1)")
      }
  }
}
