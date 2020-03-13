import Foundation
import Utility

final class Statistics {
    static let shared = Statistics()

    var executedChecks: [CheckInfo] = []
    var allViolations: [Violation] = []
    var violationsPerCheck: [CheckInfo: [Violation]] = [:]

    private init() {}

    func found(violations: [Violation], in check: CheckInfo) {
        executedChecks.append(check)
        allViolations.append(contentsOf: violations)
        violationsPerCheck[check] = violations
    }
}
