#!/usr/local/bin/swift-sh
import AnyLint // .

try Lint.reportResultsToFile(arguments: CommandLine.arguments) {
    // MARK: PseudoCheck
    try Lint.checkFilePaths(
        checkInfo: "PseudoCheck: Checks if the file `Pseudo.md` exists.",
        regex: #"^Pseudo\.md$"#,
        matchingExamples: ["Pseudo.md"],
        nonMatchingExamples: ["Pseudo.markdown", "PSEUDO.md"],
        violateIfNoMatchesFound: true
    )
}
