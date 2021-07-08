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
    fatalError()  // TODO: [cg_2021-07-02] not yet implemented
    //    log.message("Start checking \(checkInfo) ...", level: .debug)
    //    var violations: [Violation] = []
    //
    //    for filePath in filePathsToCheck.reversed() {
    //      log.message("Start reading contents of file at \(filePath) ...", level: .debug)
    //
    //      if let fileData = fileManager.contents(atPath: filePath),
    //        let fileContents = String(data: fileData, encoding: .utf8)
    //      {
    //        var newFileContents: String = fileContents
    //        let linesInFile: [String] = fileContents.components(separatedBy: .newlines)
    //
    //        // skip check in file if contains `AnyLint.skipInFile: <All or CheckInfo.ID>`
    //        let skipInFileRegex = try Regex(#"AnyLint\.skipInFile:[^\n]*([, ]All[,\s]|[, ]\#(checkInfo.id)[,\s])"#)
    //        guard !skipInFileRegex.matches(fileContents) else {
    //          log.message(
    //            "Skipping \(checkInfo) in file \(filePath) due to 'AnyLint.skipInFile' instruction ...",
    //            level: .debug
    //          )
    //          continue
    //        }
    //
    //        let skipHereRegex = try Regex(#"AnyLint\.skipHere:[^\n]*[, ]\#(checkInfo.id)"#)
    //
    //        for match in regex.matches(in: fileContents).reversed() {
    //          let fileLocation = fileContents.locationInfo(of: match.range.lowerBound)
    //
    //          log.message("Found violating match at \(locationInfo) ...", level: .debug)
    //
    //          // skip found match if contains `AnyLint.skipHere: <CheckInfo.ID>` in same line or one line before
    //          guard
    //            !linesInFile.containsLine(at: [locationInfo.line - 2, locationInfo.line - 1], matchingRegex: skipHereRegex)
    //          else {
    //            log.message("Skip reporting last match due to 'AnyLint.skipHere' instruction ...", level: .debug)
    //            continue
    //          }
    //
    //          let autoCorrection: AutoCorrection? = {
    //            guard let autoCorrectReplacement = autoCorrectReplacement else { return nil }
    //
    //            let newMatchString = regex.replaceAllCaptures(in: match.string, with: autoCorrectReplacement)
    //            return AutoCorrection(before: match.string, after: newMatchString)
    //          }()
    //
    //          if let autoCorrection = autoCorrection {
    //            guard match.string != autoCorrection.after else {
    //              // can skip auto-correction & violation reporting because auto-correct replacement is equal to matched string
    //              continue
    //            }
    //
    //            // apply auto correction
    //            newFileContents.replaceSubrange(match.range, with: autoCorrection.after)
    //            log.message("Applied autocorrection for last match ...", level: .debug)
    //          }
    //
    //          log.message("Reporting violation for \(checkInfo) in file \(filePath) at \(locationInfo) ...", level: .debug)
    //          violations.append(
    //            Violation(
    //              checkInfo: checkInfo,
    //              filePath: filePath,
    //              matchedString: match.string,
    //              locationInfo: locationInfo,
    //              appliedAutoCorrection: autoCorrection
    //            )
    //          )
    //        }
    //
    //        if newFileContents != fileContents {
    //          log.message("Rewriting contents of file \(filePath) due to autocorrection changes ...", level: .debug)
    //          try newFileContents.write(toFile: filePath, atomically: true, encoding: .utf8)
    //        }
    //      }
    //      else {
    //        log.message(
    //          "Could not read contents of file at \(filePath). Make sure it is a text file and is formatted as UTF8.",
    //          level: .warning
    //        )
    //      }
    //
    //      Statistics.shared.checkedFiles(at: [filePath])
    //    }
    //
    //    violations = violations.reversed()
    //
    //    if repeatIfAutoCorrected && violations.contains(where: { $0.appliedAutoCorrection != nil }) {
    //      log.message("Repeating check \(checkInfo) because auto-corrections were applied on last run.", level: .debug)
    //
    //      // only paths where auto-corrections were applied need to be re-checked
    //      let filePathsToReCheck = Array(Set(violations.filter { $0.appliedAutoCorrection != nil }.map { $0.filePath! }))
    //        .sorted()
    //
    //      let violationsOnRechecks = try FileContentsChecker(
    //        checkInfo: checkInfo,
    //        regex: regex,
    //        filePathsToCheck: filePathsToReCheck,
    //        autoCorrectReplacement: autoCorrectReplacement,
    //        repeatIfAutoCorrected: repeatIfAutoCorrected
    //      )
    //      .performCheck()
    //      violations.append(contentsOf: violationsOnRechecks)
    //    }
    //
    //    return violations
  }
}
