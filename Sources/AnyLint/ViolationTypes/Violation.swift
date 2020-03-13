import Foundation
import HandySwift
import Utility

/// A violation found in a check.
open class Violation {
    /// The info about the chack that caused this violation.
    public let checkInfo: CheckInfo

    /// Create a new violation.
    public init(checkInfo: CheckInfo) {
        self.checkInfo = checkInfo
    }

    func logMessage(match: Regex.Match?) {
        let message = "\(checkInfo.consoleDescription(match: match))"

        switch checkInfo.severity {
        case .info:
            log.message(message, level: .info)

        case .warning:
            log.message(message, level: .warning)

        case .error:
            log.message(message, level: .error)
        }
    }
}
