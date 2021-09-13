import Foundation
import Core
import BetterCodable

extension Severity {
  /// Use to set the default value of `Severity` instances to `error` in rules when users don't provide an explicit value.
  public enum DefaultToError: DefaultCodableStrategy {
    public static var defaultValue: Severity { .error }
  }
}

extension Regex {
  /// Use to set the default value of `Regex` instances to `.*` in rules when users don't provide an explicit value.
  public enum DefaultToMatchAllArray: DefaultCodableStrategy {
    public static var defaultValue: [Regex] { [try! Regex(".*")] }
  }
}
