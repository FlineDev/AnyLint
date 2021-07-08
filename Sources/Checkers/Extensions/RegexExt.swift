import Foundation
import Core

extension Regex: ExpressibleByStringLiteral {
  /// Constants to reference across the project.
  enum Constants {
    /// The separator indicating that next come regex options.
    static let regexOptionsSeparator: String = #"\"#

    /// Hint that the case insensitive option should be active on a Regex.
    static let caseInsensitiveRegexOption: String = "i"

    /// Hint that the case dot matches newline option should be active on a Regex.
    static let dotMatchesNewlinesRegexOption: String = "m"

    //    /// The number of newlines required in both before and after of AutoCorrections required to use diff for outputs.
    //    static let newlinesRequiredForDiffing: Int = 3
  }

  public init(
    stringLiteral value: String
  ) {
    var pattern = value
    let options: Options = {
      if value.hasSuffix(
        Constants.regexOptionsSeparator + Constants.caseInsensitiveRegexOption + Constants.dotMatchesNewlinesRegexOption
      )
        || value.hasSuffix(
          Constants.regexOptionsSeparator + Constants.dotMatchesNewlinesRegexOption
            + Constants.caseInsensitiveRegexOption
        )
      {
        pattern.removeLast(
          (Constants.regexOptionsSeparator + Constants.dotMatchesNewlinesRegexOption
            + Constants.caseInsensitiveRegexOption)
            .count
        )
        return Regex.defaultOptions.union([.ignoreCase, .dotMatchesLineSeparators])
      }
      else if value.hasSuffix(Constants.regexOptionsSeparator + Constants.caseInsensitiveRegexOption) {
        pattern.removeLast((Constants.regexOptionsSeparator + Constants.caseInsensitiveRegexOption).count)
        return Regex.defaultOptions.union([.ignoreCase])
      }
      else if value.hasSuffix(Constants.regexOptionsSeparator + Constants.dotMatchesNewlinesRegexOption) {
        pattern.removeLast((Constants.regexOptionsSeparator + Constants.dotMatchesNewlinesRegexOption).count)
        return Regex.defaultOptions.union([.dotMatchesLineSeparators])
      }
      else {
        return Regex.defaultOptions
      }
    }()

    do {
      self = try Regex(pattern, options: options)
    }
    catch {
      log.message("Failed to convert String literal '\(value)' to type Regex.", level: .error)
      log.exit(fail: true)
      exit(EXIT_FAILURE)  // only reachable in unit tests
    }
  }
}

extension Regex: ExpressibleByDictionaryLiteral {
  public init(
    dictionaryLiteral elements: (String, String)...
  ) {
    var patternElements = elements
    var options: Options = Regex.defaultOptions

    if let regexOptionsValue = elements.last(where: { $0.0 == Constants.regexOptionsSeparator })?.1 {
      patternElements.removeAll { $0.0 == Constants.regexOptionsSeparator }

      if regexOptionsValue.contains(Constants.caseInsensitiveRegexOption) {
        options.insert(.ignoreCase)
      }

      if regexOptionsValue.contains(Constants.dotMatchesNewlinesRegexOption) {
        options.insert(.dotMatchesLineSeparators)
      }
    }

    do {
      let pattern: String = patternElements.reduce(into: "") { result, element in
        result.append("(?<\(element.0)>\(element.1))")
      }
      self = try Regex(pattern, options: options)
    }
    catch {
      log.message("Failed to convert Dictionary literal '\(elements)' to type Regex.", level: .error)
      log.exit(fail: true)
      exit(EXIT_FAILURE)  // only reachable in unit tests
    }
  }
}

extension Regex {
  /// Replaces all captures groups with the given capture references. References can be numbers like `$1` and capture names like `$prefix`.
  public func replaceAllCaptures(in input: String, with template: String) -> String {
    replacingMatches(in: input, with: numerizedNamedCaptureRefs(in: template))
  }

  /// Numerizes references to named capture groups to work around missing named capture group replacement in `NSRegularExpression` APIs.
  func numerizedNamedCaptureRefs(in replacementString: String) -> String {
    let captureGroupNameRegex = Regex(#"\(\?\<([a-zA-Z0-9_-]+)\>[^\)]+\)"#)
    let captureGroupNames: [String] = captureGroupNameRegex.matches(in: pattern).map { $0.captures[0]! }
    return captureGroupNames.enumerated()
      .reduce(replacementString) { result, enumeratedGroupName in
        result.replacingOccurrences(of: "$\(enumeratedGroupName.element)", with: "$\(enumeratedGroupName.offset + 1)")
      }
  }
}
