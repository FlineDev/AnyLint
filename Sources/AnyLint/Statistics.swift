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
            switch log.outputType {
            case .console, .test:
                logViolationsToConsole()

            case .xcode:
                showViolationsInXcode()
            }
        } else {
            log.message("Performed \(executedChecks.count) check(s) without any violations.", level: .success)
        }
    }

    private func logViolationsToConsole() {
        for check in executedChecks {
            if let checkViolations = violationsPerCheck[check], checkViolations.isFilled {
                let violationsWithLocationMessage = checkViolations.filter { $0.locationMessage() != nil }

                if violationsWithLocationMessage.isFilled {
                    log.message(
                        "\("[\(check.id)]".bold) Found \(checkViolations.count) violation(s) at:",
                        level: check.severity.logLevel
                    )
                    let numerationDigits = String(violationsWithLocationMessage.count).count

                    for (index, violation) in violationsWithLocationMessage.enumerated() {
                        let violationNumString = String(format: "%0\(numerationDigits)d", index + 1)
                        let prefix = "> \(violationNumString). "
                        log.message(prefix + violation.locationMessage()!, level: check.severity.logLevel)

                        let prefixLengthWhitespaces = (0 ..< prefix.count).map { _ in " " }.joined()
                        if let appliedAutoCorrection = violation.appliedAutoCorrection {
                            for messageLine in appliedAutoCorrection.appliedMessageLines {
                                log.message(prefixLengthWhitespaces + messageLine, level: .info)
                            }
                        } else if let matchedString = violation.matchedString {
                            log.message(prefixLengthWhitespaces + "Matching string:".bold + " (trimmed & reduced whitespaces)", level: .info)
                            let matchedStringOutput = matchedString
                                .showNewlines()
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                                .replacingOccurrences(of: "        ", with: "  ")
                                .replacingOccurrences(of: "      ", with: "  ")
                                .replacingOccurrences(of: "    ", with: "  ")
                            log.message(prefixLengthWhitespaces + "> " + matchedStringOutput, level: .info)
                        }
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
    }

    private func showViolationsInXcode() {
        for severity in violationsBySeverity.keys.sorted().reversed() {
            let severityViolations = violationsBySeverity[severity]!
            for violation in severityViolations {
                let check = violation.checkInfo
                log.xcodeMessage("[\(check.id)] \(check.hint)", level: check.severity.logLevel, location: violation.locationMessage())
            }
        }
    }
}
