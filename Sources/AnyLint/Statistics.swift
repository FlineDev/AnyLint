import Foundation
import Utility

final class Statistics {
    static let shared = Statistics()

    var executedChecks: [CheckInfo] = []
    var violationsPerCheck: [CheckInfo: [Violation]] = [:]
    var violationsBySeverity: [Severity: [Violation]] = [.info: [], .warning: [], .error: []]

    var maxViolationSeverity: Severity? {
        violationsBySeverity.keys.filter { !violationsBySeverity[$0]!.isEmpty }.max { $0.rawValue < $1.rawValue }
    }

    private init() {}

    func found(violations: [Violation], in check: CheckInfo) {
        executedChecks.append(check)
        violationsPerCheck[check] = violations
        violationsBySeverity[check.severity]!.append(contentsOf: violations)
    }

    /// Use for unit testing only.
    func reset() {
        executedChecks = []
        violationsPerCheck = [:]
        violationsBySeverity = [.info: [], .warning: [], .error: []]
    }

    func logSummary() {
        if executedChecks.isEmpty {
            log.message("No checks found to perform.", level: .warning)
        } else if violationsBySeverity.values.contains(where: { $0.isFilled }) {
            for check in executedChecks {
                if let checkViolations = violationsPerCheck[check], checkViolations.isFilled {
                    let violationLocationMessages = checkViolations.compactMap { $0.locationMessage() }

                    if violationLocationMessages.isFilled {
                        log.message("\("[\(check.id)]".bold) Found \(checkViolations.count) violation(s) at:", level: check.severity.logLevel)
                        let numerationDigits = String(violationLocationMessages.count).count

                        for (index, locationMessage) in violationLocationMessages.enumerated() {
                            let violationNumString = String(format: "%0\(numerationDigits)d", index + 1)
                            log.message("> \(violationNumString). " + locationMessage, level: check.severity.logLevel)
                        }
                    } else {
                        log.message("\("[\(check.id)]".bold) Found \(checkViolations.count) violation(s).", level: check.severity.logLevel)
                    }

                    log.message(">> Hint: \(check.hint)".bold.italic, level: check.severity.logLevel)
                }
            }

            let errors = "\(violationsBySeverity[.error]!.count) error(s)"
            let warnings = "\(violationsBySeverity[.warning]!.count) warning(s)"

            log.message(
                "Performed \(executedChecks.count) check(s) and found \(errors) & \(warnings).",
                level: maxViolationSeverity!.logLevel
            )
        } else {
            log.message("Performed \(executedChecks.count) check(s) without any violations.", level: .success)
        }
    }
}
