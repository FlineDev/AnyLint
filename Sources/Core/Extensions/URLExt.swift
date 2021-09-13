import Foundation

extension URL {
  /// Returns the relative path of from the current path.
  public var relativePathFromCurrent: String {
    String(path.replacingOccurrences(of: FileManager.default.currentDirectoryPath, with: "").dropFirst())
  }
}
