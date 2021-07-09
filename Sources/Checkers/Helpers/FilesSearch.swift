import Foundation
import Core

/// Helper to search for files and filter using Regexes.
public final class FilesSearch {
  struct SearchOptions: Equatable, Hashable {
    let pathToSearch: String
    let includeFilters: [Regex]
    let excludeFilters: [Regex]
  }

  /// The shared instance.
  public static let shared = FilesSearch()

  private var cachedFilePaths: [SearchOptions: [String]] = [:]

  private init() {}

  /// Should be called whenever files within the current directory are renamed, moved, added or deleted.
  func invalidateCache() {
    cachedFilePaths = [:]
  }

  /// Returns all file paths within given `path` matching the given `include` and `exclude` filters.
  public func allFiles(
    within path: String,
    includeFilters: [Regex],
    excludeFilters: [Regex] = []
  ) -> [String] {
    let searchOptions = SearchOptions(
      pathToSearch: path,
      includeFilters: includeFilters,
      excludeFilters: excludeFilters
    )

    if let cachedFilePaths: [String] = cachedFilePaths[searchOptions] {
      return cachedFilePaths
    }

    guard let url = URL(string: path, relativeTo: FileManager.default.currentDirectoryUrl) else {
      log.message("Could not convert path '\(path)' to type URL.", level: .error)
      log.exit(fail: true)
    }

    let propKeys = [URLResourceKey.isRegularFileKey, URLResourceKey.isHiddenKey]
    guard
      let enumerator = FileManager.default.enumerator(
        at: url,
        includingPropertiesForKeys: propKeys,
        options: [],
        errorHandler: nil
      )
    else {
      log.message("Couldn't create enumerator for path '\(path)'.", level: .error)
      log.exit(fail: true)
    }

    var filePaths: [String] = []

    for case let fileUrl as URL in enumerator {
      guard
        let resourceValues = try? fileUrl.resourceValues(forKeys: [
          URLResourceKey.isRegularFileKey, URLResourceKey.isHiddenKey,
        ]),
        let isHiddenFilePath = resourceValues.isHidden,
        let isRegularFilePath = resourceValues.isRegularFile
      else {
        log.message("Could not read resource values for file at \(fileUrl.path)", level: .error)
        log.exit(fail: true)
      }

      // skip if any exclude filter applies
      if excludeFilters.contains(where: { $0.matches(fileUrl.relativePathFromCurrent) }) {
        if !isRegularFilePath {
          enumerator.skipDescendants()
        }

        continue
      }

      // skip hidden files and directories
      #if os(Linux)
        if isHiddenFilePath || fileUrl.path.contains("/.") || fileUrl.path.starts(with: ".") {
          if !isRegularFilePath {
            enumerator.skipDescendants()
          }

          continue
        }
      #else
        if isHiddenFilePath {
          if !isRegularFilePath {
            enumerator.skipDescendants()
          }

          continue
        }
      #endif

      guard isRegularFilePath, includeFilters.contains(where: { $0.matches(fileUrl.relativePathFromCurrent) }) else {
        continue
      }

      filePaths.append(fileUrl.relativePathFromCurrent)
    }

    cachedFilePaths[searchOptions] = filePaths
    return filePaths
  }
}
