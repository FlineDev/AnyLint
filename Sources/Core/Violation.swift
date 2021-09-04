import Foundation

/// A violation found in a check.
public struct Violation: Codable {
  /// The matched string that violates the check.
  public let matchedString: String?

  /// The info about the exact location of the violation within the file. Will be ignored if no `filePath` specified.
  public let fileLocation: Location?

  /// The autocorrection applied to fix this violation.
  public let appliedAutoCorrection: AutoCorrection?

  /// Initializes a violation object.
  public init(
    matchedString: String? = nil,
    fileLocation: Location? = nil,
    appliedAutoCorrection: AutoCorrection? = nil
  ) {
    self.matchedString = matchedString
    self.fileLocation = fileLocation
    self.appliedAutoCorrection = appliedAutoCorrection
  }
}
