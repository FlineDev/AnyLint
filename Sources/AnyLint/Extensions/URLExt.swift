import Foundation
import Utility

extension URL {
    var relativePathFromCurrent: String {
        String(path.replacingOccurrences(of: fileManager.currentDirectoryPath, with: "").dropFirst())
    }
}
