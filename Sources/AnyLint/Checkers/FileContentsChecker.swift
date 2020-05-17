import Foundation
import Utility

struct FileContentsChecker {
    let checkInfo: CheckInfo
    let regex: Regex
    let filePathsToCheck: [String]
    let autoCorrectReplacement: String?
}

extension FileContentsChecker: Checker {
    func performCheck() throws -> [Violation] { // swiftlint:disable:this function_body_length
        log.message("Start checking \(checkInfo) ...", level: .debug)
        var violations: [Violation] = []

        for filePath in filePathsToCheck.reversed() {
            log.message("Start reading contents of file at \(filePath) ...", level: .debug)

            if let fileData = fileManager.contents(atPath: filePath), let fileContents = String(data: fileData, encoding: .utf8) {
                var newFileContents: String = fileContents
                let linesInFile: [String] = fileContents.components(separatedBy: .newlines)

                // skip check in file if contains `AnyLint.skipInFile: <All or CheckInfo.ID>`
                let skipInFileRegex = try Regex(#"AnyLint\.skipInFile:[^\n]*([, ]All[,\s]|[, ]\#(checkInfo.id)[,\s])"#)
                guard !skipInFileRegex.matches(fileContents) else {
                    log.message("Skipping \(checkInfo) in file \(filePath) due to 'AnyLint.skipInFile' instruction ...", level: .debug)
                    continue
                }

                let skipHereRegex = try Regex(#"AnyLint\.skipHere:[^\n]*[, ]\#(checkInfo.id)"#)

                for match in regex.matches(in: fileContents).reversed() {
                    // TODO: [cg_2020-03-13] use capture group named 'pointer' if exists
                    let locationInfo = fileContents.locationInfo(of: match.range.lowerBound)

                    log.message("Found violating match at \(locationInfo) ...", level: .debug)

                    // skip found match if contains `AnyLint.skipHere: <CheckInfo.ID>` in same line or one line before
                    guard !linesInFile.containsLine(at: [locationInfo.line - 2, locationInfo.line - 1], matchingRegex: skipHereRegex) else {
                        log.message("Skip reporting last match due to 'AnyLint.skipHere' instruction ...", level: .debug)
                        continue
                    }

                    let autoCorrection: AutoCorrection? = {
                        guard let autoCorrectReplacement = autoCorrectReplacement else { return nil }

                        let newMatchString = regex.replaceAllCaptures(in: match.string, with: autoCorrectReplacement)
                        return AutoCorrection(before: match.string, after: newMatchString)
                    }()

                    if let autoCorrection = autoCorrection {
                        guard match.string != autoCorrection.after else {
                            // can skip auto-correction & violation reporting because auto-correct replacement is equal to matched string
                            continue
                        }

                        // apply auto correction
                        newFileContents.replaceSubrange(match.range, with: autoCorrection.after)
                        log.message("Applied autocorrection for last match ...", level: .debug)
                    }

                    log.message("Reporting violation for \(checkInfo) in file \(filePath) at \(locationInfo) ...", level: .debug)
                    violations.append(
                        Violation(
                            checkInfo: checkInfo,
                            filePath: filePath,
                            matchedString: match.string,
                            locationInfo: locationInfo,
                            appliedAutoCorrection: autoCorrection
                        )
                    )
                }

                if newFileContents != fileContents {
                    log.message("Rewriting contents of file \(filePath) due to autocorrection changes ...", level: .debug)
                    try newFileContents.write(toFile: filePath, atomically: true, encoding: .utf8)
                }
            } else {
                log.message(
                    "Could not read contents of file at \(filePath). Make sure it is a text file and is formatted as UTF8.",
                    level: .warning
                )
            }

            Statistics.shared.checkedFiles(at: [filePath])
        }

        return violations.reversed()
    }
}
