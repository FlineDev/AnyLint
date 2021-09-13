import Foundation
import BetterCodable

/// A violation found in a check.
public struct Violation: Codable, Equatable {
  /// The exact time this violation was discovered. Needed for sorting purposes.
  @DateValue<Date.DefaultToNowISO8601>
  public var discoverDate: Date

  /// The matched string that violates the check.
  public let matchedString: String?

  /// The info about the exact location of the violation within the file. Will be ignored if no `filePath` specified.
  public let location: Location?

  /// The autocorrection applied to fix this violation.
  public let appliedAutoCorrection: AutoCorrection?

  /// A custom violation message.
  public let message: String?

  /// Initializes a violation object.
  public init(
    discoverDate: Date = Date(),
    matchedString: String? = nil,
    location: Location? = nil,
    appliedAutoCorrection: AutoCorrection? = nil,
    message: String? = nil
  ) {
    self.discoverDate = discoverDate
    self.matchedString = matchedString
    self.location = location
    self.appliedAutoCorrection = appliedAutoCorrection
    self.message = message
  }
}

extension Violation: Comparable {
  public static func < (lhs: Violation, rhs: Violation) -> Bool {
    lhs.discoverDate < rhs.discoverDate
  }
}
