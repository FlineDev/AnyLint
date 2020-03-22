import Foundation
import Utility

struct FilePathsChecker {
    let checkInfo: CheckInfo
    let regex: Regex
    let filePathsToCheck: [String]
    let autoCorrectReplacement: String?
    let violateIfNoMatchesFound: Bool
}

extension FilePathsChecker: Checker {
    func performCheck() throws -> [Violation] {
        var violations: [Violation] = []

        if violateIfNoMatchesFound {
            let matchingFilePathsCount = filePathsToCheck.filter { regex.matches($0) }.count
            if matchingFilePathsCount <= 0 {
                violations.append(
                    Violation(checkInfo: checkInfo, filePath: nil, locationInfo: nil, appliedAutoCorrection: nil)
                )
            }
        } else {
            for filePath in filePathsToCheck where regex.matches(filePath) {
                let appliedAutoCorrection: AutoCorrection? = try {
                    guard let autoCorrectReplacement = autoCorrectReplacement else { return nil }

                    let newFilePath = regex.replaceAllCaptures(in: filePath, with: autoCorrectReplacement)
                    try fileManager.moveFileSafely(from: filePath, to: newFilePath)

                    return AutoCorrection(before: filePath, after: newFilePath)
                }()

                violations.append(
                    Violation(checkInfo: checkInfo, filePath: filePath, locationInfo: nil, appliedAutoCorrection: appliedAutoCorrection)
                )
            }
        }

        return violations
    }
}
