import Foundation
import HandySwift
import Utility

/// A violation found in a check.
public struct Violation {
    /// The info about the chack that caused this violation.
    public let checkInfo: CheckInfo

    /// The file path the violation is related to.
    public let filePath: String?

    /// The info about the exact location of the violation within the file. Will be ignored if no `filePath` specified.
    public let locationInfo: String.LocationInfo?

    func logMessage() {
        let checkInfoMessage = "[\(checkInfo.id)] \(checkInfo.hint)"

        guard let filePath = filePath else {
            log.message(checkInfoMessage, level: checkInfo.severity.logLevel)
            return
        }

        guard let locationInfo = locationInfo else {
            log.message("\(filePath): \(checkInfoMessage)", level: checkInfo.severity.logLevel)
            return
        }

        log.message("\(filePath):\(locationInfo.line):\(locationInfo.charInLine): \(checkInfoMessage)", level: checkInfo.severity.logLevel)
    }
}
