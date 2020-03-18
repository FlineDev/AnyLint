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
