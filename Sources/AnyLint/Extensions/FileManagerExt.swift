import Foundation

extension FileManager {
  /// Moves a file from one path to another, making sure that all directories are created and no files are overwritten.
  public func moveFileSafely(from sourcePath: String, to targetPath: String) throws {
    guard fileExists(atPath: sourcePath) else {
      log.message("No file found at \(sourcePath) to move.", level: .error)
      log.exit(status: .failure)
      return  // only reachable in unit tests
    }

    guard !fileExists(atPath: targetPath) || sourcePath.lowercased() == targetPath.lowercased() else {
      log.message("File already exists at target path \(targetPath) – can't move from \(sourcePath).", level: .warning)
      return
    }

    let targetParentDirectoryPath = targetPath.parentDirectoryPath
    if !fileExists(atPath: targetParentDirectoryPath) {
      try createDirectory(atPath: targetParentDirectoryPath, withIntermediateDirectories: true, attributes: nil)
    }

    guard fileExistsAndIsDirectory(atPath: targetParentDirectoryPath) else {
      log.message("Expected \(targetParentDirectoryPath) to be a directory.", level: .error)
      log.exit(status: .failure)
      return  // only reachable in unit tests
    }

    if sourcePath.lowercased() == targetPath.lowercased() {
      // workaround issues on case insensitive file systems
      let temporaryTargetPath = targetPath + UUID().uuidString
      try moveItem(atPath: sourcePath, toPath: temporaryTargetPath)
      try moveItem(atPath: temporaryTargetPath, toPath: targetPath)
    }
    else {
      try moveItem(atPath: sourcePath, toPath: targetPath)
    }

    FilesSearch.shared.invalidateCache()
  }
}

extension FileManager {
  /// The current directory `URL`.
  public var currentDirectoryUrl: URL {
    URL(string: currentDirectoryPath)!
  }

  /// Checks if a file exists and the given paths and is a directory.
  public func fileExistsAndIsDirectory(atPath path: String) -> Bool {
    var isDirectory: ObjCBool = false
    return fileExists(atPath: path, isDirectory: &isDirectory) && isDirectory.boolValue
  }
}
