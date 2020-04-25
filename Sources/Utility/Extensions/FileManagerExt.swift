import Foundation

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
