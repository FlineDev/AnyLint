import Foundation

extension FileManager {
    var currentDirectoryUrl: URL {
        URL(string: currentDirectoryPath)!
    }
}
