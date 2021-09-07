import Foundation

/// Info about the exact location of a character in a given file.
public struct Location: Codable, Equatable {
  /// The path to the file.
  public let filePath: String

  /// The row or line number of the location.
  public let row: Int?

  /// The column or character index within a line of the location.
  public let column: Int?

  /// Initializes a file location object.
  public init(
    filePath: String,
    row: Int? = nil,
    column: Int? = nil
  ) {
    self.filePath = filePath
    self.row = row
    self.column = column
  }

  /// Returns a string representation of a violations filled with path and line information if available.
  public func locationMessage(pathType: String.PathType) -> String {
    if let row = row {
      if let column = column {
        return "\(filePath.path(type: pathType)):\(row):\(column):"
      }

      return "\(filePath.path(type: pathType)):\(row):"
    }

    return "\(filePath.path(type: pathType))"
  }
}
