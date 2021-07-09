import Foundation
import Core

/// The checker for the `FileContents` configuration. Runs regex-based chacks on contents of files.
public struct FileContentsChecker {
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

  /// If set to `true`, the contents check will be repeated until there are no longer any changes when applying autocorrection.
  public let repeatIfAutoCorrected: Bool
}

extension FileContentsChecker: Checker {
  public func performCheck() throws -> [Violation] {
    var violations: [Violation] = []

    for filePath in filePathsToCheck.reversed() {
      if let fileData = FileManager.default.contents(atPath: filePath),
        let fileContents = String(data: fileData, encoding: .utf8)
      {
        var newFileContents: String = fileContents
        let linesInFile: [String] = fileContents.components(separatedBy: .newlines)

        // skip check in file if contains `AnyLint.skipInFile: <All or CheckInfo.ID>`
        let skipInFileRegex = try Regex(#"AnyLint\.skipInFile:[^\n]*([, ]All[,\s]|[, ]\#(id)[,\s])"#)
        guard !skipInFileRegex.matches(fileContents) else { continue }

        let skipHereRegex = try Regex(#"AnyLint\.skipHere:[^\n]*[, ]\#(id)"#)

        for match in regex.matches(in: fileContents).reversed() {
          let fileLocation = fileContents.fileLocation(of: match.range.lowerBound)

          // skip found match if contains `AnyLint.skipHere: <CheckInfo.ID>` in same line or one line before
          guard
            !linesInFile.containsLine(at: [fileLocation.row - 2, fileLocation.row - 1], matchingRegex: skipHereRegex)
          else { continue }

          let autoCorrection: AutoCorrection? = {
            guard let autoCorrectReplacement = autoCorrectReplacement else { return nil }

            let newMatchString = regex.replaceAllCaptures(in: match.string, with: autoCorrectReplacement)
            return AutoCorrection(before: match.string, after: newMatchString)
          }()

          if let autoCorrection = autoCorrection {
            guard match.string != autoCorrection.after else {
              // can skip auto-correction & violation reporting because auto-correct replacement is equal to matched string
              continue
            }

            // apply auto correction
            newFileContents.replaceSubrange(match.range, with: autoCorrection.after)
          }

          violations.append(
            Violation(
              filePath: filePath,
              matchedString: match.string,
              fileLocation: fileLocation,
              appliedAutoCorrection: autoCorrection
            )
          )
        }

        if newFileContents != fileContents {
          try newFileContents.write(toFile: filePath, atomically: true, encoding: .utf8)
        }
      }
      else {
        log.message(
          "Could not read contents of file at \(filePath). Make sure it is a text file and is formatted as UTF8.",
          level: .warning
        )
      }
    }

    violations = violations.reversed()

    if repeatIfAutoCorrected && violations.contains(where: { $0.appliedAutoCorrection != nil }) {
      // only paths where auto-corrections were applied need to be re-checked
      let filePathsToReCheck = Array(Set(violations.filter { $0.appliedAutoCorrection != nil }.map { $0.filePath! }))
        .sorted()

      let violationsOnRechecks = try FileContentsChecker(
        id: id,
        hint: hint,
        severity: severity,
        regex: regex,
        filePathsToCheck: filePathsToReCheck,
        autoCorrectReplacement: autoCorrectReplacement,
        repeatIfAutoCorrected: repeatIfAutoCorrected
      )
      .performCheck()
      violations.append(contentsOf: violationsOnRechecks)
    }

    return violations
  }
}
