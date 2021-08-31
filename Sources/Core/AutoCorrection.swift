import Foundation

/// Information about an autocorrection.
public struct AutoCorrection: Codable {
  private enum Constants {
    /// The number of newlines required in both before and after of AutoCorrections required to use diff for outputs.
    static let newlinesRequiredForDiffing: Int = 3
  }

  /// The matching text before applying the autocorrection.
  public let before: String

  /// The matching text after applying the autocorrection.
  public let after: String

  // TODO: [cg_2021-08-31] consider migrating over to https://github.com/pointfreeco/swift-custom-dump#diff
  var appliedMessageLines: [String] {
    if useDiffOutput, #available(OSX 10.15, *) {
      var lines: [String] = ["Autocorrection applied, the diff is: (+ added, - removed)"]

      let beforeLines = before.components(separatedBy: .newlines)
      let afterLines = after.components(separatedBy: .newlines)

      for difference in afterLines.difference(from: beforeLines).sorted() {
        switch difference {
        case let .insert(offset, element, _):
          lines.append("+ [L\(offset + 1)] \(element)".green)

        case let .remove(offset, element, _):
          lines.append("- [L\(offset + 1)] \(element)".red)
        }
      }

      return lines
    }
    else {
      return [
        "Autocorrection applied, the diff is: (+ added, - removed)",
        "- \(before.showWhitespacesAndNewlines())".red,
        "+ \(after.showWhitespacesAndNewlines())".green,
      ]
    }
  }

  var useDiffOutput: Bool {
    before.components(separatedBy: .newlines).count >= Constants.newlinesRequiredForDiffing
      || after.components(separatedBy: .newlines).count >= Constants.newlinesRequiredForDiffing
  }

  /// Initializes an autocorrection.
  public init(
    before: String,
    after: String
  ) {
    self.before = before
    self.after = after
  }
}

// TODO: make the autocorrection diff sorted by line number
@available(OSX 10.15, *)
extension CollectionDifference.Change: Comparable where ChangeElement == String {
  public static func < (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case let (.remove(leftOffset, _, _), .remove(rightOffset, _, _)),
      let (.insert(leftOffset, _, _), .insert(rightOffset, _, _)):
      return leftOffset < rightOffset

    case let (.remove(leftOffset, _, _), .insert(rightOffset, _, _)):
      return leftOffset < rightOffset || true

    case let (.insert(leftOffset, _, _), .remove(rightOffset, _, _)):
      return leftOffset < rightOffset || false
    }
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case let (.remove(leftOffset, _, _), .remove(rightOffset, _, _)),
      let (.insert(leftOffset, _, _), .insert(rightOffset, _, _)):
      return leftOffset == rightOffset

    case (.remove, .insert), (.insert, .remove):
      return false
    }
  }
}
