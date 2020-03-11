import Foundation

extension String {
    var absolutePath: String {
        guard let url = URL(string: self) else {
            log.message("Could not convert path '\(self)' to type URL.", level: .error)
            exit(EXIT_FAILURE)
        }

        return url.absoluteString
    }

    var parentDirectoryPath: String {
        guard let url = URL(string: self) else {
            log.message("Could not convert path '\(self)' to type URL.", level: .error)
            exit(EXIT_FAILURE)
        }

        return url.deletingLastPathComponent().absoluteString
    }

    func appendingPathComponent(_ pathComponent: String) -> String {
        guard let pathUrl = URL(string: self) else {
            log.message("Could not convert path '\(self)' to type URL.", level: .error)
            exit(EXIT_FAILURE)
        }

        return pathUrl.appendingPathComponent(pathComponent).absoluteString
    }
}
