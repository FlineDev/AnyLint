import Foundation

extension Date {
  /// Returns a sample Date for testing purposes. Use the same seed to get the same date.
  public static func sample(seed: Int) -> Date {
    Date(timeIntervalSinceReferenceDate: Double(seed) * 60 * 60)
  }
}
