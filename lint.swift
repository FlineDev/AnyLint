#!/usr/local/bin/swift-sh
import AnyLint // .

// MARK: - Reusables
let swiftSourceFiles: Regex = #"Sources/.*\.swift"#
let swiftTestFiles: Regex = #"Tests/.*\.swift"#

// MARK: - File Content Checks
try Lint.checkFileContents(
    checkInfo: CheckInfo(
        id: "empty_method_body",
        hint: "Don't use whitespace or newlines for the body of empty methods – use empty bodies like in `func doSomething() {}` instead.",
        severity: .error
    ),
    regex: ["declaration": #"(init|func [^\(\s]+)\([^{]*\)"#, "spacing": #"\s*"#, "body": #"\{\s+\}"#],
    matchingExamples: [
        "init() { }",
        "init() {\n\n}",
        "init(\n    x: Int,\n    y: Int\n) { }",
        "func foo2bar()  { }",
        "func foo2bar(x: Int, y: Int)  { }",
        "func foo2bar(\n    x: Int,\n    y: Int\n) {\n    \n}",
    ],
    nonMatchingExamples: ["init() { /* comment */ }", "init() {}", "func foo2bar() {}", "func foo2bar(x: Int, y: Int) {}"],
    includeFilters: [swiftSourceFiles, swiftTestFiles],
    autoCorrectReplacement: "$declaration {}",
    autoCorrectExamples: [
        AutoCorrection(before: "init()  { }", after: "init() {}"),
        AutoCorrection(before: "init(x: Int, y: Int)  { }", after: "init(x: Int, y: Int) {}"),
        AutoCorrection(before: "init()\n{\n    \n}", after: "init() {}"),
        AutoCorrection(before: "init(\n    x: Int,\n    y: Int\n) {\n    \n}", after: "init(\n    x: Int,\n    y: Int\n) {}"),
        AutoCorrection(before: "func foo2bar()  { }", after: "func foo2bar() {}"),
        AutoCorrection(before: "func foo2bar(x: Int, y: Int)  { }", after: "func foo2bar(x: Int, y: Int) {}"),
        AutoCorrection(before: "func foo2bar()\n{\n    \n}", after: "func foo2bar() {}"),
        AutoCorrection(before: "func foo2bar(\n    x: Int,\n    y: Int\n) {\n    \n}", after: "func foo2bar(\n    x: Int,\n    y: Int\n) {}"),
    ]
)

// MARK: - File Path Checks
try Lint.checkFilePaths(
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

try Lint.checkFilePaths(
    checkInfo: CheckInfo(
        id: "readme_path",
        hint: "The README file should be named exactly `README.md`.",
        severity: .error
    ),
    regex: #"^(.*/?)([Rr][Ee][Aa][Dd][Mm][Ee]\.markdown|readme\.md|Readme\.md|ReadMe\.md)$"#,
    matchingExamples: ["README.markdown", "readme.md", "ReadMe.md"],
    nonMatchingExamples: ["README.md", "CHANGELOG.md", "CONTRIBUTING.md", "api/help.md"],
    autoCorrectReplacement: "$1README.md",
    autoCorrectExamples: [
        AutoCorrection(before: "api/readme.md", after: "api/README.md"),
        AutoCorrection(before: "ReadMe.md", after: "README.md"),
        AutoCorrection(before: "README.markdown", after: "README.md"),
    ]
)
Lint.logSummaryAndExit()
