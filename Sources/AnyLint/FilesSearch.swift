import Foundation
import Utility

/// Helper to search for files and filter using Regexes.
public enum FilesSearch {
    static func allFiles(within path: String, includeFilters: [Regex], excludeFilters: [Regex] = []) -> [String] {
        guard let url = URL(string: path, relativeTo: fileManager.currentDirectoryUrl) else {
            log.message("Could not convert path '\(path)' to type URL.", level: .error)
            log.exit(status: .failure)
            return [] // only reachable in unit tests
        }

        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [URLResourceKey.isRegularFileKey, URLResourceKey.isHiddenKey],
            options: [],
            errorHandler: nil
        ) else {
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
            if isHiddenFilePath {
                if !isRegularFilePath {
                    enumerator.skipDescendants()
                }
                continue
            }

            if isRegularFilePath, includeFilters.contains(where: { $0.matches(fileUrl.relativePathFromCurrent) }) {
                filePaths.append(fileUrl.relativePathFromCurrent)
            }
        }

        return filePaths
    }
}
