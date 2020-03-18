import Foundation
import Rainbow
import Utility

/// A violation found in a check.
public struct Violation {
    /// The info about the chack that caused this violation.
    public let checkInfo: CheckInfo

    /// The file path the violation is related to.
    public let filePath: String?

    /// The info about the exact location of the violation within the file. Will be ignored if no `filePath` specified.
    public let locationInfo: String.LocationInfo?

    init(checkInfo: CheckInfo, filePath: String? = nil, locationInfo: String.LocationInfo? = nil) {
        self.checkInfo = checkInfo
        self.filePath = filePath
        self.locationInfo = locationInfo
    }

    func locationMessage() -> String? {
        guard let filePath = filePath else { return nil }
        guard let locationInfo = locationInfo else { return filePath }
        return "\(filePath):\(locationInfo.line):\(locationInfo.charInLine)"
    }
}
