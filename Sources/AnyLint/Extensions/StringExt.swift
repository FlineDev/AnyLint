import Foundation

/// `Regex` is a swifty regex engine built on top of the NSRegularExpression api.
public typealias Regex = Utility.Regex

extension String {
  /// Info about the exact location of a character in a given file.
  public typealias LocationInfo = (line: Int, charInLine: Int)

  /// Returns the location info for a given line index.
  public func locationInfo(of index: String.Index) -> LocationInfo {
    let prefix = self[startIndex..<index]
    let prefixLines = prefix.components(separatedBy: .newlines)
    guard let lastPrefixLine = prefixLines.last else { return (line: 1, charInLine: 1) }

    let charInLine = prefix.last == "\n" ? 1 : lastPrefixLine.count + 1
    return (line: prefixLines.count, charInLine: charInLine)
  }

  func showNewlines() -> String {
    components(separatedBy: .newlines).joined(separator: #"\n"#)
  }

  func showWhitespaces() -> String {
    components(separatedBy: .whitespaces).joined(separator: "␣")
  }

  func showWhitespacesAndNewlines() -> String {
    showNewlines().showWhitespaces()
  }
}

extension String {
  /// The type of a given file path.
  public enum PathType {
    /// The relative path.
    case relative

    /// The absolute path.
    case absolute
  }

  /// Returns the absolute path for a path given relative to the current directory.
  public var absolutePath: String {
    guard !self.starts(with: fileManager.currentDirectoryUrl.path) else { return self }
    return fileManager.currentDirectoryUrl.appendingPathComponent(self).path
  }

  /// Returns the relative path for a path given relative to the current directory.
  public var relativePath: String {
    guard self.starts(with: fileManager.currentDirectoryUrl.path) else { return self }
    return replacingOccurrences(of: fileManager.currentDirectoryUrl.path, with: "")
  }

  /// Returns the parent directory path.
  public var parentDirectoryPath: String {
    let url = URL(fileURLWithPath: self)
    guard url.pathComponents.count > 1 else { return fileManager.currentDirectoryPath }
    return url.deletingLastPathComponent().absoluteString
  }

  /// Returns the path with the given type related to the current directory.
  public func path(type: PathType) -> String {
    switch type {
    case .absolute:
      return absolutePath

    case .relative:
      return relativePath
    }
  }

  /// Returns the path with a components appended at it.
  public func appendingPathComponent(_ pathComponent: String) -> String {
    guard let pathUrl = URL(string: self) else {
      log.message("Could not convert path '\(self)' to type URL.", level: .error)
      log.exit(status: .failure)
      return ""  // only reachable in unit tests
    }

    return pathUrl.appendingPathComponent(pathComponent).absoluteString
  }
}
