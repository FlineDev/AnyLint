import Foundation
import Core
import OrderedCollections

/// The linting output type. Can be merged from multiple
public typealias LintResults = OrderedDictionary<Severity, OrderedDictionary<CheckInfo, [Violation]>>

extension LintResults {
  var allExecutedChecks: [CheckInfo] {
    values.reduce(into: []) { $0.append(contentsOf: $1.keys) }
  }

  var allFoundViolations: [Violation] {
    values.reduce(into: []) { $0.append(contentsOf: $1.values.flatMap { $0 }) }
  }

  /// The highest severity with at least one violation.
  func maxViolationSeverity(excludeAutocorrected: Bool) -> Severity? {
    for severity in Severity.allCases.sorted().reversed() {
      if let severityViolations = self[severity],
        severityViolations.values.elements.contains(where: { !$0.isEmpty })
      {
        return severity
      }
    }

    return nil
  }

  /// Merges the given lint results into this one.
  public mutating func mergeResults(_ other: LintResults) {
    merge(other) { currentDict, newDict in
      currentDict.merging(newDict) { currentViolations, newViolations in
        currentViolations + newViolations
      }
    }
  }

  /// Appends the violations for the provided check to the results.
  public mutating func appendViolations(_ violations: [Violation], forCheck checkInfo: CheckInfo) {
    assert(
      keys.contains(checkInfo.severity),
      "Trying to add violations for severity \(checkInfo.severity) to LintResults without having initialized the severity key."
    )

    self[checkInfo.severity]![checkInfo] = violations
  }

  /// Logs the summary of the violations in the specified output format.
  public func report(outputFormat: OutputFormat) {
    let executedChecks = allExecutedChecks

    if executedChecks.isEmpty {
      log.message("No checks found to perform.", level: .warning)
    }
    else if values.contains(where: { $0.values.isFilled }) {
      switch outputFormat {
      case .commandLine:
        reportToConsole()

      case .xcode:
        reportToXcode()

      case .json:
        reportToFile(at: "anylint-results.json")
      }
    }
    else {
      log.message(
        "Performed \(executedChecks.count) check(s) without any violations.",
        level: .success
      )
    }
  }

  /// Used to get validations for a specific severity level.
  ///
  /// - Parameters:
  ///   - severity: The severity to filter by.
  ///   - excludeAutocorrected: If `true`, autocorrected violations will not be returned, else returns all violations of the given severity level.
  /// - Returns: The violations for a specific severity level.
  public func violations(severity: Severity, excludeAutocorrected: Bool) -> [Violation] {
    guard let violations = self[severity]?.values.elements.flatMap({ $0 }) else { return [] }
    guard excludeAutocorrected else { return violations }
    return violations.filter { $0.appliedAutoCorrection == nil }
  }

  /// Used to get validations for a specific check.
  ///
  /// - Parameters:
  ///   - check: The `CheckInfo` object to filter by.
  ///   - excludeAutocorrected: If `true`, autocorrected violations will not be returned, else returns all violations of the given severity level.
  /// - Returns: The violations for a specific check.
  public func violations(check: CheckInfo, excludeAutocorrected: Bool) -> [Violation] {
    guard let violations: [Violation] = self[check.severity]?[check] else { return [] }
    guard excludeAutocorrected else { return violations }
    return violations.filter { $0.appliedAutoCorrection == nil }
  }

  func reportToConsole() {
    for check in allExecutedChecks {
      let checkViolations = violations(check: check, excludeAutocorrected: false)

      if checkViolations.isFilled {
        let violationsWithLocationMessage = checkViolations.filter { $0.fileLocation != nil }

        if violationsWithLocationMessage.isFilled {
          log.message(
            "\("[\(check.id)]".bold) Found \(checkViolations.count) violation(s) at:",
            level: check.severity.logLevel
          )
          let numerationDigits = String(violationsWithLocationMessage.count).count

          for (index, violation) in violationsWithLocationMessage.enumerated() {
            let violationNumString = String(format: "%0\(numerationDigits)d", index + 1)
            let prefix = "> \(violationNumString). "
            log.message(
              prefix + violation.fileLocation!.locationMessage(pathType: .relative),
              level: check.severity.logLevel
            )

            let prefixLengthWhitespaces = (0..<prefix.count).map { _ in " " }.joined()
            if let appliedAutoCorrection = violation.appliedAutoCorrection {
              for messageLine in appliedAutoCorrection.appliedMessageLines {
                log.message(prefixLengthWhitespaces + messageLine, level: .info)
              }
            }
            else if let matchedString = violation.matchedString {
              log.message(
                prefixLengthWhitespaces + "Matching string:".bold + " (trimmed & reduced whitespaces)",
                level: .info
              )
              let matchedStringOutput =
                matchedString
                .showNewlines()
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "        ", with: "  ")
                .replacingOccurrences(of: "      ", with: "  ")
                .replacingOccurrences(of: "    ", with: "  ")
              log.message(prefixLengthWhitespaces + "> " + matchedStringOutput, level: .info)
            }
          }
        }
        else {
          log.message(
            "\("[\(check.id)]".bold) Found \(checkViolations.count) violation(s).",
            level: check.severity.logLevel
          )
        }

        log.message(">> Hint: \(check.hint)".bold.italic, level: check.severity.logLevel)
      }
    }

    let errors = "\(violations(severity: .error, excludeAutocorrected: false).count) error(s)"
    let warnings = "\(violations(severity: .warning, excludeAutocorrected: false).count) warning(s)"

    log.message(
      "Performed \(allExecutedChecks.count) check(s) and found \(errors) & \(warnings).",
      // TODO: [cg_2021-09-03] forward option "exclude autocorrected" to use here rather than using `false`
      level: maxViolationSeverity(excludeAutocorrected: false)?.logLevel ?? .info
    )
  }

  func reportToXcode() {
    for severity in keys.sorted().reversed() {
      guard let checkResultsAtSeverity = self[severity] else { continue }

      for (checkInfo, violations) in checkResultsAtSeverity {
        for violation in violations where violation.appliedAutoCorrection == nil {
          log.message(
            "[\(checkInfo.id)] \(checkInfo.hint)",
            level: severity.logLevel,
            fileLocation: violation.fileLocation
          )
        }
      }

    }
  }

  func reportToFile(at path: String) {
    let resultFileUrl = URL(fileURLWithPath: path)

    do {
      let resultsData = try JSONEncoder.iso.encode(self)
      try resultsData.write(to: resultFileUrl)

      log.message("Successfully executed checks & reported results to file at \(resultFileUrl.path)", level: .info)
    }
    catch {
      log.message("Failed to report results to file at \(resultFileUrl.path).", level: .error)
      log.exit(fail: true)
    }
  }
}
