#!/usr/local/bin/swift-sh
import AnyLint // .

// MARK: - Reusables
let swiftSourceFiles: Regex = #"Sources/.*\.swift"#
let swiftTestFiles: Regex = #"Tests/.*\.swift"#

// MARK: - File Content Checks
Lint.checkFileContents(
    checkInfo: CheckInfo(
        id: "closure_params_parantheses",
        hint: "Don't use parantheses around non-typed parameters in a closure.",
        severity: .error
    ),
    regex: try Regex(
        #"""
        (?<prefix>\{\s*)
        (?<openingBrace>\()
        (?<parameters>(?!self)[^):]+)
        (?<closingBrace>\))
        (?<suffix>\s*in)
        """#.removeNewlinesBetweenCaptureGroups()
    ),
    matchingExamples: ["closure = { (param) in", "func do() { (param) in"],
    nonMatchingExamples: ["closure { (self) in", "func do() { (self) in"],
    includeFilters: [swiftSourceFiles, swiftTestFiles],
    autoCorrectReplacement: "$prefix$parameters$suffix",
    autoCorrectExamples: [
        (before: "closure = { (param) in", after: "closure { param in"),
        (before: "func do() { (param) in", after: "func do() { param in"),
    ]
)

// MARK: - File Path Checks
Lint.checkFilePaths(
    checkInfo: CheckInfo(
        id: "readme",
        hint: "Each project should have a README.md file, explaining how to use or contribute to the project.",
        severity: .error
    ),
    regex: #"^README\.md$"#,
    matchingExamples: ["README.md"],
    nonMatchingExamples: ["README.markdown", "Readme.md", "ReadMe.md"],
    violateIfNoMatchesFound: true
)

Lint.logSummaryAndExit()
