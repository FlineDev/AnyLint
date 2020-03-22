import Foundation

extension String {
    /// Returns the absolute path for a path given relative to the current directory.
    public var absolutePath: String {
        guard let url = URL(string: self, relativeTo: fileManager.currentDirectoryUrl) else {
            log.message("Could not convert path '\(self)' to type URL.", level: .error)
            log.exit(status: .failure)
            return "" // only reachable in unit tests
        }

        return url.absoluteString
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
