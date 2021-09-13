import Foundation

extension JSONDecoder {
  public static var iso: JSONDecoder {
    let decoder = JSONDecoder()
    // TODO: uncomment once following issue is fixed: https://github.com/marksands/BetterCodable/issues/45
    //    decoder.dateDecodingStrategy = .iso8601
    return decoder
  }
}
