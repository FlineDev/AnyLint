import Foundation

extension FileManager {
    /// The current directory `URL`.
    public var currentDirectoryUrl: URL {
        URL(string: currentDirectoryPath)!
    }
}
