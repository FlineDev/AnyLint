import Foundation
import Utility

final class Statistics {
    static let shared = Statistics()

    var executedChecks: [CheckInfo] = []
    var violationsPerCheck: [CheckInfo: [Violation]] = [:]
    var violationsBySeverity: [Severity: [Violation]] = [.info: [], .warning: [], .error: []]

    var maxViolationSeverity: Severity? {
        violationsBySeverity.keys.max { $0.rawValue < $1.rawValue }
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
        } else if violationsBySeverity.isEmpty {
            log.message("Performed \(executedChecks.count) checks without any violations.", level: .info)
        } else {
            let errors = "\(violationsBySeverity[.error]!.count) errors"
            let warnings = "\(violationsBySeverity[.warning]!.count) warnings"

            log.message(
                "Performed \(executedChecks.count) checks and found \(errors) & \(warnings).",
                level: maxViolationSeverity!.logLevel
            )
        }
    }
}
