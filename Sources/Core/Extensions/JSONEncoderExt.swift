import Foundation

extension JSONEncoder {
  public static var iso: JSONEncoder {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.outputFormatting = .prettyPrinted
    return encoder
  }
}
