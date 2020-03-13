import Foundation

open class FileContentViolation: Violation {
    /// The file path.
    public let filePath: String

    /// The line number of the violation.
    public let lineNum: Int

    /// The character within the violations line.
    public let charInLine: Int

    public init(checkInfo: CheckInfo, filePath: String, lineNum: Int, charInLine: Int) {
        self.filePath = filePath
        self.lineNum = lineNum
        self.charInLine = charInLine

        super.init(checkInfo: checkInfo)
    }
}
