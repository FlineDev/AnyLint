import Foundation

extension String {
    /// Info about the exact location of a character in a given file.
    public typealias LocationInfo = (line: Int, charInLine: Int)

    func locationInfo(of index: String.Index) -> LocationInfo {
        let prefix = self[startIndex ..< index]
        let prefixLines = prefix.split(separator: "\n")
        guard let lastPrefixLine = prefixLines.last else { return (line: 0, charInLine: 0) }

        return (line: prefixLines.count, charInLine: lastPrefixLine.count)
    }
}
