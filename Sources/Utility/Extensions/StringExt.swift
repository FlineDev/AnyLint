import Foundation

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
        guard let url = URL(string: self) else {
            log.message("Could not convert path '\(self)' to type URL.", level: .error)
            log.exit(status: .failure)
            return "" // only reachable in unit tests
        }

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
            return "" // only reachable in unit tests
        }

        return pathUrl.appendingPathComponent(pathComponent).absoluteString
    }
}
