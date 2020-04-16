import Foundation
import Utility

struct FileContentsChecker {
    let checkInfo: CheckInfo
    let regex: Regex
    let filePathsToCheck: [String]
    let autoCorrectReplacement: String?
}

extension FileContentsChecker: Checker {
    func performCheck() throws -> [Violation] {
        var violations: [Violation] = []

        for filePath in filePathsToCheck.reversed() {
            if let fileData = fileManager.contents(atPath: filePath), let fileContents = String(data: fileData, encoding: .utf8) {
                var newFileContents: String = fileContents
                let linesInFile: [String] = fileContents.components(separatedBy: .newlines)

                // skip check in file if contains `AnyLint.skipInFile: <All or CheckInfo.ID>`
                let skipInFileRegex = try Regex(#"AnyLint\.skipInFile:[^\n]*([, ]All[,\s]|[, ]\#(checkInfo.id)[,\s])"#)
                guard !skipInFileRegex.matches(fileContents) else { continue }

                let skipHereRegex = try Regex(#"AnyLint\.skipHere:[^\n]*[, ]\#(checkInfo.id)"#)

                for match in regex.matches(in: fileContents).reversed() {
                    // TODO: [cg_2020-03-13] use capture group named 'pointer' if exists
                    let locationInfo = fileContents.locationInfo(of: match.range.lowerBound)

                    // skip found match if contains `AnyLint.skipHere: <CheckInfo.ID>` in same line or one line before
                    guard !linesInFile.containsLine(at: [locationInfo.line - 2, locationInfo.line - 1], matchingRegex: skipHereRegex) else { continue }

                    let appliedAutoCorrection: AutoCorrection? = {
                        guard let autoCorrectReplacement = autoCorrectReplacement else { return nil }

                        let newMatchString = regex.replaceAllCaptures(in: match.string, with: autoCorrectReplacement)
                        newFileContents.replaceSubrange(match.range, with: newMatchString)

                        return AutoCorrection(before: match.string, after: newMatchString)
                    }()

                    violations.append(
                        Violation(
                            checkInfo: checkInfo,
                            filePath: filePath,
                            matchedString: match.string,
                            locationInfo: locationInfo,
                            appliedAutoCorrection: appliedAutoCorrection
                        )
                    )
                }

                if newFileContents != fileContents {
                    try newFileContents.write(toFile: filePath, atomically: true, encoding: .utf8)
                }
            } else {
                log.message(
                    "Could not read contents of file at \(filePath). Make sure it is a text file and is formatted as UTF8.",
                    level: .warning
                )
            }
        }

        return violations.reversed()
    }
}
