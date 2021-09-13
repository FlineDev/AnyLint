import Foundation

extension JSONEncoder {
  public static var iso: JSONEncoder {
    let encoder = JSONEncoder()
    // TODO: uncomment once following issue is fixed: https://github.com/marksands/BetterCodable/issues/45
    //    encoder.dateEncodingStrategy = .iso8601
    encoder.outputFormatting = .prettyPrinted
    return encoder
  }
}
