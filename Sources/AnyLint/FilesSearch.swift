import Foundation
import HandySwift
import Utility

/// Helper to search for files and filter using Regexes.
public enum FilesSearch {
    static func allFiles(within path: String, includeFilters: [Regex], excludeFilters: [Regex] = []) -> [String] {
        guard let url = URL(string: path, relativeTo: fileManager.currentDirectoryUrl) else {
            log.message("Could not convert path '\(path)' to type URL.", level: .error)
            exit(EXIT_FAILURE)
        }

        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [URLResourceKey.isRegularFileKey, URLResourceKey.isHiddenKey],
            options: [],
            errorHandler: nil
        ) else {
            log.message("Couldn't create enumerator for path '\(path)'.", level: .error)
            exit(EXIT_FAILURE)
        }

        var filePaths: [String] = []

        for case let fileUrl as URL in enumerator {
            // skip if no include filter applies
            guard includeFilters.contains(where: { $0.matches(fileUrl.relativePath) }) else {
                enumerator.skipDescendants()
                continue
            }

            // skip if any exclude filter applies
            if excludeFilters.contains(where: { $0.matches(fileUrl.relativePath) }) {
                enumerator.skipDescendants()
                continue
            }

            // TODO: [cg_2020-03-15] make sure not to skip any hidden directories, that were explicitly specified in includeFilters

            guard
                let resourceValues = try? fileUrl.resourceValues(forKeys: [URLResourceKey.isRegularFileKey, URLResourceKey.isHiddenKey]),
                let isHiddenFilePath = resourceValues.isHidden,
                let isRegularFilePath = resourceValues.isRegularFile
            else {
                log.message("Could not read resource values for file at \(fileUrl.path)", level: .error)
                exit(EXIT_FAILURE)
            }

            // skip hidden files and directories
            if isHiddenFilePath {
                enumerator.skipDescendants()
                continue
            }

            if isRegularFilePath {
                filePaths.append(fileUrl.relativePath)
            }
        }

        return filePaths
    }
}
