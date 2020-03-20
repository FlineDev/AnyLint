#!/usr/local/bin/swift-sh
import AnyLint // .

// MARK: - Reusables
let swiftSourceFiles: Regex = #"Sources/.*\.swift"#
let swiftTestFiles: Regex = #"Tests/.*\.swift"#

// MARK: - File Path Checks
try Lint.checkFilePaths(
    checkInfo: CheckInfo(id: "readme", hint: "Each project should have a README.md file, explaining how to use or contribute to the project."),
    regex: #"^README\.md$"#,
    matchingExamples: ["README.md"],
    nonMatchingExamples: ["README.markdown", "Readme.md", "ReadMe.md"],
    violateIfNoMatchesFound: true
)

try Lint.checkFilePaths(
    checkInfo: CheckInfo(id: "readme_path", hint: "The README file should be named exactly `README.md`."),
    regex: #"^(.*/)?([Rr][Ee][Aa][Dd][Mm][Ee]\.markdown|readme\.md|Readme\.md|ReadMe\.md)$"#,
    matchingExamples: ["README.markdown", "readme.md", "ReadMe.md"],
    nonMatchingExamples: ["README.md", "CHANGELOG.md", "CONTRIBUTING.md", "api/help.md"],
    autoCorrectReplacement: "$1README.md",
    autoCorrectExamples: [
        AutoCorrection(before: "api/readme.md", after: "api/README.md"),
        AutoCorrection(before: "ReadMe.md", after: "README.md"),
        AutoCorrection(before: "README.markdown", after: "README.md"),
    ]
)

// MARK: - File Content Checks
try Lint.checkFileContents(
    checkInfo: CheckInfo(id: "empty_method_body", hint: "Don't use whitespace or newlines for the body of empty methods."),
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

try Lint.checkFileContents(
    checkInfo: CheckInfo(id: "empty_todo", hint: "`// TODO:` comments should not be empty."),
    regex: #"// TODO: ?(\[[\d\-_a-z]+\])? *\n"#,
    matchingExamples: ["// TODO:\n", "// TODO: [2020-03-19]\n", "// TODO: [cg_2020-03-19]  \n"],
    nonMatchingExamples: ["// TODO: refactor", "// TODO: not yet implemented", "// TODO: [cg_2020-03-19] not yet implemented"],
    includeFilters: [swiftSourceFiles, swiftTestFiles]
)

try Lint.checkFileContents(
    checkInfo: CheckInfo(id: "empty_type", hint: "Don't keep empty types in code without commenting inside why they are needed."),
    regex: #"(class|protocol|struct|enum) [^\{]+\{\s*\}"#,
    matchingExamples: ["class Foo {}", "enum Constants {\n    \n}", "struct MyViewModel(x: Int, y: Int, closure: () -> Void) {}"],
    nonMatchingExamples: ["class Foo { /* TODO: not yet implemented */ }", "func foo() {}", "init() {}", "enum Bar { case x, y }"],
    includeFilters: [swiftSourceFiles, swiftTestFiles]
)

try Lint.checkFileContents(
    checkInfo: CheckInfo(id: "if_as_guard", hint: "Don't use an if statement to just return – use guard for such cases instead."),
    regex: #" +if [^\{]+\{\s*return\s*[^\}]*\}(?! *else)"#,
    matchingExamples: [" if x == 5 { return }", " if x == 5 {\n    return nil\n}", " if x == 5 { return 500 }", " if x == 5 { return do(x: 500, y: 200) }"],
    nonMatchingExamples: [" if x == 5 {\n    let y = 200\n    return y\n}", " if x == 5 { someMethod(x: 500, y: 200) }", " if x == 500 { return } else {"],
    includeFilters: [swiftSourceFiles, swiftTestFiles]
)


try Lint.checkFileContents(
    checkInfo: CheckInfo(id: "late_force_unwrapping_3", hint: "Don't use ? first to force unwrap later – directly unwrap within the parantheses."),
    regex: [
        "openingBrace": #"\("#,
        "callPart1": #"[^\s\?\.]+"#,
        "separator1": #"\?\."#,
        "callPart2": #"[^\s\?\.]+"#,
        "separator2": #"\?\."#,
        "callPart3": #"[^\s\?\.]+"#,
        "separator3": #"\?\."#,
        "callPart4": #"[^\s\?\.]+"#,
        "closingBraceUnwrap": #"\)!"#,
    ],
    matchingExamples: ["let x = (viewModel?.user?.profile?.imagePath)!\n"],
    nonMatchingExamples: ["call(x: (viewModel?.username)!)", "let x = viewModel!.user!.profile!.imagePath\n"],
    includeFilters: [swiftSourceFiles, swiftTestFiles],
    autoCorrectReplacement: "$callPart1!.$callPart2!.$callPart3!.$callPart4",
    autoCorrectExamples: [
        AutoCorrection(before: "let x = (viewModel?.user?.profile?.imagePath)!\n", after: "let x = viewModel!.user!.profile!.imagePath\n"),
    ]
)

try Lint.checkFileContents(
    checkInfo: CheckInfo(id: "late_force_unwrapping_2", hint: "Don't use ? first to force unwrap later – directly unwrap within the parantheses."),
    regex: [
        "openingBrace": #"\("#,
        "callPart1": #"[^\s\?\.]+"#,
        "separator1": #"\?\."#,
        "callPart2": #"[^\s\?\.]+"#,
        "separator2": #"\?\."#,
        "callPart3": #"[^\s\?\.]+"#,
        "closingBraceUnwrap": #"\)!"#,
    ],
    matchingExamples: ["call(x: (viewModel?.profile?.username)!)"],
    nonMatchingExamples: ["let x = (viewModel?.user?.profile?.imagePath)!\n", "let x = viewModel!.profile!.imagePath\n"],
    includeFilters: [swiftSourceFiles, swiftTestFiles],
    autoCorrectReplacement: "$callPart1!.$callPart2!.$callPart3",
    autoCorrectExamples: [
        AutoCorrection(before: "let x = (viewModel?.profile?.imagePath)!\n", after: "let x = viewModel!.profile!.imagePath\n"),
    ]
)

try Lint.checkFileContents(
    checkInfo: CheckInfo(id: "late_force_unwrapping_1", hint: "Don't use ? first to force unwrap later – directly unwrap within the parantheses."),
    regex: [
        "openingBrace": #"\("#,
        "callPart1": #"[^\s\?\.]+"#,
        "separator1": #"\?\."#,
        "callPart2": #"[^\s\?\.]+"#,
        "closingBraceUnwrap": #"\)!"#,
    ],
    matchingExamples: ["call(x: (viewModel?.username)!)"],
    nonMatchingExamples: ["call(x: (viewModel?.profile?.username)!)", "call(x: viewModel!.username)"],
    includeFilters: [swiftSourceFiles, swiftTestFiles],
    autoCorrectReplacement: "$callPart1!.$callPart2",
    autoCorrectExamples: [
        AutoCorrection(before: "call(x: (viewModel?.username)!)", after: "call(x: viewModel!.username)"),
    ]
)

try Lint.checkFileContents(
    checkInfo: CheckInfo(id: "logger", hint: "Don't use `print` – use `log.message` instead."),
    regex: #"print\([^\n]+\)"#,
    matchingExamples: [#"print("Hellow World!")"#, #"print(5)"#, #"print(\n    "hi"\n)"#],
    nonMatchingExamples: [#"log.message("Hello world!")"#],
    includeFilters: [swiftSourceFiles, swiftTestFiles],
    excludeFilters: [#"Sources/.*/Logger\.swift"#]
)

// MARK: - Log Summary
Lint.logSummaryAndExit()
