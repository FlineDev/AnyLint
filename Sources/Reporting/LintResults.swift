import Foundation
import Core
import OrderedCollections

/// The linting output type. Can be merged from multiple instances into one.
public struct LintResults {
  /// The checks and their validations accessible by severity level.
  public var checkViolationsBySeverity: Dictionary<Severity, Dictionary<Check, [Violation]>>

  public init() {
    self.checkViolationsBySeverity = [:]
  }

  /// Returns a list of all executed checks.
  public var allExecutedChecks: [Check] {
    checkViolationsBySeverity.values.reduce(into: []) { $0.append(contentsOf: $1.keys) }.sorted()
  }

  /// Returns a list of all found violations.
  public var allFoundViolations: [Violation] {
    checkViolationsBySeverity.values.reduce(into: []) { $0.append(contentsOf: $1.values.flatMap { $0 }) }.sorted()
  }

  /// The highest severity with at least one violation.
  func maxViolationSeverity(excludeAutocorrected: Bool) -> Severity? {
    for severity in Severity.allCases.sorted().reversed() {
      if let severityViolations = checkViolationsBySeverity[severity],
        severityViolations.values.contains(where: { !$0.isEmpty })
      {
        return severity
      }
    }

    return nil
  }

  /// Merges the given lint results into this one.
  public mutating func mergeResults(_ other: LintResults) {
    checkViolationsBySeverity.merge(other.checkViolationsBySeverity) { currentDict, newDict in
      currentDict.merging(newDict) { currentViolations, newViolations in
        currentViolations + newViolations
      }
    }
  }

  /// Appends the violations for the provided check to the results.
  public mutating func appendViolations(_ violations: [Violation], forCheck check: Check) {
    assert(
      checkViolationsBySeverity.keys.contains(check.severity),
      "Trying to add violations for severity \(check.severity) to LintResults without having initialized the severity key."
    )

    checkViolationsBySeverity[check.severity]![check] = violations
  }

  /// Logs the summary of the violations in the specified output format.
  public func report(outputFormat: OutputFormat) {
    let executedChecks = allExecutedChecks

    if executedChecks.isEmpty {
      log.message("No checks found to perform.", level: .warning)
    }
    else if checkViolationsBySeverity.values.contains(where: { $0.values.isFilled }) {
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
    guard let violations = checkViolationsBySeverity[severity]?.values.flatMap({ $0 }) else { return [] }
    guard excludeAutocorrected else { return violations }
    return violations.filter { $0.appliedAutoCorrection == nil }
  }

  /// Used to get validations for a specific check.
  ///
  /// - Parameters:
  ///   - check: The `Check` object to filter by.
  ///   - excludeAutocorrected: If `true`, autocorrected violations will not be returned, else returns all violations of the given severity level.
  /// - Returns: The violations for a specific check.
  public func violations(check: Check, excludeAutocorrected: Bool) -> [Violation] {
    guard let violations: [Violation] = checkViolationsBySeverity[check.severity]?[check] else { return [] }
    guard excludeAutocorrected else { return violations }
    return violations.filter { $0.appliedAutoCorrection == nil }
  }

  func reportToConsole() {
    for check in allExecutedChecks {
      let checkViolations = violations(check: check, excludeAutocorrected: false)

      if checkViolations.isFilled {
        let violationsWithLocationMessage = checkViolations.filter { $0.location != nil }

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
              prefix + violation.location!.locationMessage(pathType: .relative),
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
    for severity in checkViolationsBySeverity.keys.sorted().reversed() {
      guard let checkResultsAtSeverity = checkViolationsBySeverity[severity] else { continue }

      for (check, violations) in checkResultsAtSeverity {
        for violation in violations where violation.appliedAutoCorrection == nil {
          log.message(
            "[\(check.id)] \(check.hint)",
            level: severity.logLevel,
            location: violation.location
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

enum LintResultsDecodingError: Error {
  case unknownSeverityRawValue(String)
  case unknownCheckRawValue(String)
}

/// Custom ``Codable`` implementation due to a Swift bug with custom key types: https://bugs.swift.org/browse/SR-7788
extension LintResults: Codable {
  public init(
    from decoder: Decoder
  ) throws {
    let rawKeyedDictionary: [String: [String: [Violation]]] = try .init(from: decoder)

    self.checkViolationsBySeverity = [:]

    for (rawSeverity, checkRawValueViolationsDict) in rawKeyedDictionary {
      guard let severity = Severity(rawValue: rawSeverity) else {
        throw LintResultsDecodingError.unknownSeverityRawValue(rawSeverity)
      }

      var checkViolationsDict: [Check: [Violation]] = .init()

      for (checkRawValue, violations) in checkRawValueViolationsDict {
        guard let check = Check(rawValue: checkRawValue) else {
          throw LintResultsDecodingError.unknownCheckRawValue(checkRawValue)
        }

        checkViolationsDict[check] = violations
      }

      self.checkViolationsBySeverity[severity] = checkViolationsDict
    }
  }

  public func encode(to encoder: Encoder) throws {
    var rawKeyedOuterDict: Dictionary<String, Dictionary<String, [Violation]>> = .init()

    for (severity, checkViolationsDict) in checkViolationsBySeverity {
      var rawKeyedInnerDict: Dictionary<String, [Violation]> = .init()

      for (check, violations) in checkViolationsDict {
        rawKeyedInnerDict[check.rawValue] = violations
      }

      rawKeyedOuterDict[severity.rawValue] = rawKeyedInnerDict
    }

    var container = encoder.singleValueContainer()
    try container.encode(rawKeyedOuterDict)
  }
}

extension LintResults: ExpressibleByDictionaryLiteral {
  public init(
    dictionaryLiteral elements: (Severity, Dictionary<Check, [Violation]>)...
  ) {
    var newDict: Dictionary<Severity, Dictionary<Check, [Violation]>> = .init()

    for (key, value) in elements {
      newDict[key] = value
    }

    self.checkViolationsBySeverity = newDict
  }
}

extension LintResults: Equatable {}
