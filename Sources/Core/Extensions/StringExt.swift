import Foundation

extension String {
  /// Returns the location info for a given line index.
  public func fileLocation(of index: String.Index) -> FileLocation {
    let prefix = self[startIndex..<index]
    let prefixLines = prefix.components(separatedBy: .newlines)
    guard let lastPrefixLine = prefixLines.last else { return .init(row: 1, column: 1) }

    let charInLine = prefix.last == "\n" ? 1 : lastPrefixLine.count + 1
    return .init(row: prefixLines.count, column: charInLine)
  }

  /// Returns a string that shows newlines as `\n`.
  public func showNewlines() -> String {
    components(separatedBy: .newlines).joined(separator: #"\n"#)
  }

  /// Returns a string that shows whitespaces as `␣`.
  public func showWhitespaces() -> String {
    components(separatedBy: .whitespaces).joined(separator: "␣")
  }

  /// Returns a string that shows newlines as `\n` and whitespaces as `␣`.
  public func showWhitespacesAndNewlines() -> String {
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
    guard !self.starts(with: FileManager.default.currentDirectoryUrl.path) else { return self }
    return FileManager.default.currentDirectoryUrl.appendingPathComponent(self).path
  }

  /// Returns the relative path for a path given relative to the current directory.
  public var relativePath: String {
    guard self.starts(with: FileManager.default.currentDirectoryUrl.path) else { return self }
    return replacingOccurrences(of: FileManager.default.currentDirectoryUrl.path, with: "")
  }

  /// Returns the parent directory path.
  public var parentDirectoryPath: String {
    let url = URL(fileURLWithPath: self)
    guard url.pathComponents.count > 1 else { return FileManager.default.currentDirectoryPath }
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
      log.exit(fail: true)
      return ""  // only reachable in unit tests
    }

    return pathUrl.appendingPathComponent(pathComponent).absoluteString
  }
}
