import Foundation

/// A violation found in a check.
public struct Violation: Codable, Equatable {
  /// The matched string that violates the check.
  public let matchedString: String?

  /// The info about the exact location of the violation within the file. Will be ignored if no `filePath` specified.
  public let location: Location?

  /// The autocorrection applied to fix this violation.
  public let appliedAutoCorrection: AutoCorrection?

  /// Initializes a violation object.
  public init(
    matchedString: String? = nil,
    location: Location? = nil,
    appliedAutoCorrection: AutoCorrection? = nil
  ) {
    self.matchedString = matchedString
    self.location = location
    self.appliedAutoCorrection = appliedAutoCorrection
  }
}
