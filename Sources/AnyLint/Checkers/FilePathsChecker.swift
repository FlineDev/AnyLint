import Foundation
import HandySwift
import Utility

struct FilePathsChecker {
    let checkInfo: CheckInfo
    let regex: Regex
    let filePathsToCheck: [String]
    let violateIfNoMatchesFound: Bool
}

extension FilePathsChecker: Checker {
    func performCheck() -> [Violation] {
        var violations: [Violation] = []

        if violateIfNoMatchesFound {
            let matchingFilePathsCount = filePathsToCheck.filter { regex.matches($0) }.count
            if matchingFilePathsCount <= 0 {
                violations.append(
                    Violation(
                        checkInfo: checkInfo,
                        filePath: nil,
                        locationInfo: nil
                    )
                )
            }
        } else {
            for filePath in filePathsToCheck {
                for match in regex.matches(in: filePath) {
                    // TODO: [cg_2020-03-13] use capture group named 'pointer' if exists
                    let locationInfo = filePath.locationInfo(of: match.range.lowerBound)

                    // TODO: [cg_2020-03-13] autocorrect if autocorrection is available
                    violations.append(
                        Violation(
                            checkInfo: checkInfo,
                            filePath: filePath,
                            locationInfo: locationInfo
                        )
                    )
                }
            }
        }

        return violations
    }
}
