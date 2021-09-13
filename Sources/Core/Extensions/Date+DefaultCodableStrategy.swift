import Foundation
import BetterCodable

extension Date {
  /// Use to set the default value of `Date` instances to `Date.now` in rules when users don't provide an explicit value.
  public enum DefaultToNow: DefaultCodableStrategy {
    public static var defaultValue: Date { Date() }
  }
}
