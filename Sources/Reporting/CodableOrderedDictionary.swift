import Foundation
import OrderedCollections

/// Workaround for a Bug in Swift to encode/decode keys properly. See https://bugs.swift.org/browse/SR-7788.
/// Inspired by: https://www.fivestars.blog/articles/codable-swift-dictionaries/
@propertyWrapper
public struct CodableOrderedDictionary<Key: Hashable & RawRepresentable, Value: Codable>: Codable
where Key.RawValue: Codable & Hashable {
  public var wrappedValue: OrderedDictionary<Key, Value>

  public init() {
    wrappedValue = [:]
  }

  public init(
    wrappedValue: OrderedDictionary<Key, Value>
  ) {
    self.wrappedValue = wrappedValue
  }

  public init(
    from decoder: Decoder
  ) throws {
    let container = try decoder.singleValueContainer()
    let rawKeyedDict = try container.decode([Key.RawValue: Value].self)

    wrappedValue = [:]
    for (rawKey, value) in rawKeyedDict {
      guard let key = Key(rawValue: rawKey) else {
        throw DecodingError.dataCorruptedError(
          in: container,
          debugDescription:
            "Invalid key: cannot initialize '\(Key.self)' from invalid '\(Key.RawValue.self)' value '\(rawKey)'"
        )
      }
      wrappedValue[key] = value
    }
  }

  public func encode(to encoder: Encoder) throws {
    let rawKeyedDictionary = OrderedDictionary(uniqueKeysWithValues: wrappedValue.map { ($0.rawValue, $1) })
    var container = encoder.singleValueContainer()
    try container.encode(rawKeyedDictionary)
  }
}
