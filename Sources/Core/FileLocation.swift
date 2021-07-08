import Foundation

/// Info about the exact location of a character in a given file.
public struct FileLocation: Codable {
  /// The row or line number of the location.
  public let row: Int

  /// The column or character index within a line of the location.
  public let column: Int

  /// Initializes a file location object.
  public init(
    row: Int,
    column: Int
  ) {
    self.row = row
    self.column = column
  }
}
