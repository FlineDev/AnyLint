import Foundation

/// A violation found in a check.
public struct Violation: Codable {
  /// The file path the violation is related to.
  public let filePath: String?

  /// The matched string that violates the check.
  public let matchedString: String?

  /// The info about the exact location of the violation within the file. Will be ignored if no `filePath` specified.
  public let fileLocation: FileLocation?

  /// The autocorrection applied to fix this violation.
  public let appliedAutoCorrection: AutoCorrection?

  /// Initializes a violation object.
  public init(
    filePath: String? = nil,
    matchedString: String? = nil,
    fileLocation: FileLocation? = nil,
    appliedAutoCorrection: AutoCorrection? = nil
  ) {
    self.filePath = filePath
    self.matchedString = matchedString
    self.fileLocation = fileLocation
    self.appliedAutoCorrection = appliedAutoCorrection
  }

  /// Returns a string representation of a violations filled with path and line information if available.
  public func locationMessage(pathType: String.PathType) -> String? {
    guard let filePath = filePath else { return nil }
    guard let fileLocation = fileLocation else { return filePath.path(type: pathType) }
    return "\(filePath.path(type: pathType)):\(fileLocation.row):\(fileLocation.column):"
  }
}
