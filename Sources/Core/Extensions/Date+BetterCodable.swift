import Foundation
import BetterCodable

extension Date {
  /// Use to set the default value of `Date` instances to `Date.now` in rules when users don't provide an explicit value.
  public enum DefaultToNowISO8601: DateValueCodableStrategy {
    public static func decode(_ value: String) throws -> Date {
      (try? JSONDecoder.iso.decode(Date.self, from: value.data(using: .utf8)!)) ?? Date()
    }

    public static func encode(_ date: Date) -> String {
      String(data: try! JSONEncoder.iso.encode(date), encoding: .utf8)!
    }
  }
}

// TODO: remove these once the related PR is merged: https://github.com/marksands/BetterCodable/pull/43
extension DateValue: Equatable {
  public static func == (lhs: DateValue<Formatter>, rhs: DateValue<Formatter>) -> Bool {
    return lhs.wrappedValue == rhs.wrappedValue
  }
}

extension DateValue: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(wrappedValue)
  }
}
