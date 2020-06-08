import Foundation
import Utility

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
    public func allFiles( // swiftlint:disable:this function_body_length
        within path: String,
        includeFilters: [Regex],
        excludeFilters: [Regex] = []
    ) -> [String] {
        log.message(
            "Start searching for matching files in path \(path) with includeFilters \(includeFilters) and excludeFilters \(excludeFilters) ...",
            level: .debug
        )

        let searchOptions = SearchOptions(pathToSearch: path, includeFilters: includeFilters, excludeFilters: excludeFilters)
        if let cachedFilePaths: [String] = cachedFilePaths[searchOptions] {
            log.message("A file search with exactly the above search options was already done and was not invalidated, using cached results ...", level: .debug)
            return cachedFilePaths
        }

        guard let url = URL(string: path, relativeTo: fileManager.currentDirectoryUrl) else {
            log.message("Could not convert path '\(path)' to type URL.", level: .error)
            log.exit(status: .failure)
            return [] // only reachable in unit tests
        }

        let propKeys = [URLResourceKey.isRegularFileKey, URLResourceKey.isHiddenKey]
        guard let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: propKeys, options: [], errorHandler: nil) else {
            log.message("Couldn't create enumerator for path '\(path)'.", level: .error)
            log.exit(status: .failure)
            return [] // only reachable in unit tests
        }

        var filePaths: [String] = []

        for case let fileUrl as URL in enumerator {
            guard
                let resourceValues = try? fileUrl.resourceValues(forKeys: [URLResourceKey.isRegularFileKey, URLResourceKey.isHiddenKey]),
                let isHiddenFilePath = resourceValues.isHidden,
                let isRegularFilePath = resourceValues.isRegularFile
            else {
                log.message("Could not read resource values for file at \(fileUrl.path)", level: .error)
                log.exit(status: .failure)
                return [] // only reachable in unit tests
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

            guard isRegularFilePath, includeFilters.contains(where: { $0.matches(fileUrl.relativePathFromCurrent) }) else { continue }

            filePaths.append(fileUrl.relativePathFromCurrent)
        }

        cachedFilePaths[searchOptions] = filePaths
        return filePaths
    }
}
