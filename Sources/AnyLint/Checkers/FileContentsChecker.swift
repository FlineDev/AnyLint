import Foundation
import Utility

struct FileContentsChecker {
    let checkInfo: CheckInfo
    let regex: Regex
    let filePathsToCheck: [String]
}

extension FileContentsChecker: Checker {
    func performCheck() -> [Violation] {
        var violations: [Violation] = []

        for filePath in filePathsToCheck {
            if let fileData = fileManager.contents(atPath: filePath), let fileContents = String(data: fileData, encoding: .utf8) {
                for match in regex.matches(in: fileContents) {
                    // TODO: [cg_2020-03-13] use capture group named 'pointer' if exists
                    let locationInfo = fileContents.locationInfo(of: match.range.lowerBound)

                    // TODO: [cg_2020-03-13] autocorrect if autocorrection is available
                    violations.append(
                        Violation(
                            checkInfo: checkInfo,
                            filePath: filePath,
                            locationInfo: locationInfo
                        )
                    )
                }
            } else {
                log.message(
                    "Could not read contents of file at \(filePath). Make sure it is a text file and is formatted as UTF8.",
                    level: .warning
                )
            }
        }

        return violations
    }
}
