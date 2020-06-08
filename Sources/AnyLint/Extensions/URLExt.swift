import Foundation
import Utility

extension URL {
    /// Returns the relative path of from the current path.
    public var relativePathFromCurrent: String {
        String(path.replacingOccurrences(of: fileManager.currentDirectoryPath, with: "").dropFirst())
    }
}
