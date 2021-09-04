import Foundation
import Core

/// The checker for the `FilePaths` configuration. Runs regex-based chacks on file paths.
public struct FilePathsChecker {
  /// The identifier of the check defined here. Can be used when defining exceptions within files for specific lint checks.
  public let id: String

  /// The hint to be shown as guidance on what the issue is and how to fix it. Can reference any capture groups in the first regex parameter (e.g. `contentRegex`).
  public let hint: String

  /// The severity level for the report in case the check fails.
  public let severity: Severity

  /// The regular expression to use.
  public let regex: Regex

  /// The file paths to check.
  public let filePathsToCheck: [String]

  /// The optional replacement template string for replacing using capture groups.
  public let autoCorrectReplacement: String?

  /// If set to `true`, then the check will violate if no matches found, otherwise it will report every match as a violation.
  public let violateIfNoMatchesFound: Bool
}

extension FilePathsChecker: Checker {
  public func performCheck() throws -> [Violation] {
    var violations: [Violation] = []

    if violateIfNoMatchesFound {
      let matchingFilePathsCount = filePathsToCheck.filter { regex.matches($0) }.count
      if matchingFilePathsCount <= 0 {
        violations.append(
          Violation(fileLocation: nil, appliedAutoCorrection: nil)
        )
      }
    }
    else {
      for filePath in filePathsToCheck where regex.matches(filePath) {
        let appliedAutoCorrection: AutoCorrection? = try {
          guard let autoCorrectReplacement = autoCorrectReplacement else { return nil }

          let newFilePath = regex.replaceAllCaptures(in: filePath, with: autoCorrectReplacement)
          try FileManager.default.moveFileSafely(from: filePath, to: newFilePath)

          return AutoCorrection(before: filePath, after: newFilePath)
        }()

        violations.append(
          Violation(
            fileLocation: .init(filePath: filePath),
            appliedAutoCorrection: appliedAutoCorrection
          )
        )
      }
    }

    return violations
  }
}
