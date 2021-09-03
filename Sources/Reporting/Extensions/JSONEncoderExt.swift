import Foundation

extension JSONEncoder {
  static var iso: Self {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    return encoder
  }
}
