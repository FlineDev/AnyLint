import Foundation
import Utility

final class Statistics {
    static let `default`: Statistics = Statistics()

    var executedChecks: [CheckInfo] = []
    var violationsPerCheck: [CheckInfo: [Violation]] = [:]
    var violationsBySeverity: [Severity: [Violation]] = [.info: [], .warning: [], .error: []]
    var filesChecked: Set<String> = []

    var maxViolationSeverity: Severity? {
        violationsBySeverity.keys.filter { !violationsBySeverity[$0]!.isEmpty }.max { $0.rawValue < $1.rawValue }
    }

    func checkedFiles(at filePaths: [String]) {
        filePaths.forEach { filesChecked.insert($0) }
    }

    func found(violations: [CheckInfo: [Violation]]) {
        for (checkInfo, checkViolations) in violations {
            executedChecks.append(checkInfo)
            violationsPerCheck[checkInfo] = checkViolations
            violationsBySeverity[checkInfo.severity]!.append(contentsOf: checkViolations)
        }
    }

    func merge(other: Statistics) {
        found(violations: other.violationsPerCheck)
    }

    /// Use for unit testing only.
    func reset() {
        executedChecks = []
        violationsPerCheck = [:]
        violationsBySeverity = [.info: [], .warning: [], .error: []]
        filesChecked = []
    }

    func logValidationSummary() {
        guard log.outputType != .xcode else {
            log.message("Performing validations only while reporting for Xcode is probably misuse of the `-l` / `--validate` option.", level: .warning)
            return
        }

        if executedChecks.isEmpty {
            log.message("No checks found to validate.", level: .warning)
        } else {
            log.message(
                "Performed \(executedChecks.count) validation(s) in \(filesChecked.count) file(s) without any issues.",
                level: .success
            )
        }
    }

    func logCheckSummary() {
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
            log.message(
                "Performed \(executedChecks.count) check(s) in \(filesChecked.count) file(s) without any violations.",
                level: .success
            )
        }
    }

    func violations(severity: Severity, excludeAutocorrected: Bool) -> [Violation] {
        let violations: [Violation] = violationsBySeverity[severity]!
        guard excludeAutocorrected else { return violations }
        return violations.filter { $0.appliedAutoCorrection == nil }
    }

    private func logViolationsToConsole() {
        for check in executedChecks {
            if let checkViolations = violationsPerCheck[check], checkViolations.isFilled {
                let violationsWithLocationMessage = checkViolations.filter { $0.locationMessage(pathType: .relative) != nil }

                if violationsWithLocationMessage.isFilled {
                    log.message(
                        "\("[\(check.id)]".bold) Found \(checkViolations.count) violation(s) at:",
                        level: check.severity.logLevel
                    )
                    let numerationDigits = String(violationsWithLocationMessage.count).count

                    for (index, violation) in violationsWithLocationMessage.enumerated() {
                        let violationNumString = String(format: "%0\(numerationDigits)d", index + 1)
                        let prefix = "> \(violationNumString). "
                        log.message(prefix + violation.locationMessage(pathType: .relative)!, level: check.severity.logLevel)

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
            "Performed \(executedChecks.count) check(s) in \(filesChecked.count) file(s) and found \(errors) & \(warnings).",
            level: maxViolationSeverity!.logLevel
        )
    }

    private func showViolationsInXcode() {
        for severity in violationsBySeverity.keys.sorted().reversed() {
            let severityViolations = violationsBySeverity[severity]!
            for violation in severityViolations where violation.appliedAutoCorrection == nil {
                let check = violation.checkInfo
                log.xcodeMessage(
                    "[\(check.id)] \(check.hint)",
                    level: check.severity.logLevel,
                    location: violation.locationMessage(pathType: .absolute)
                )
            }
        }
    }
}

extension Statistics: Codable {
    enum CodingKeys: String, CodingKey {
        case violationsPerCheck
    }
}
