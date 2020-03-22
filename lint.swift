#!/usr/local/bin/swift-sh
import AnyLint // .

// MARK: - Variables
let swiftSourceFiles: Regex = #"Sources/.*\.swift"#
let swiftTestFiles: Regex = #"Tests/.*\.swift"#
let readmeFile: Regex = #"README\.md"#

// MARK: -
// MARK: empty_method_body
try Lint.checkFileContents(
    checkInfo: "empty_method_body: Don't use whitespace or newlines for the body of empty methods.",
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

// MARK: empty_todo
try Lint.checkFileContents(
    checkInfo: "empty_todo: `// TODO:` comments should not be empty.",
    regex: #"// TODO: ?(\[[\d\-_a-z]+\])? *\n"#,
    matchingExamples: ["// TODO:\n", "// TODO: [2020-03-19]\n", "// TODO: [cg_2020-03-19]  \n"],
    nonMatchingExamples: ["// TODO: refactor", "// TODO: not yet implemented", "// TODO: [cg_2020-03-19] not yet implemented"],
    includeFilters: [swiftSourceFiles, swiftTestFiles]
)

// MARK: empty_type
try Lint.checkFileContents(
    checkInfo: "empty_type: Don't keep empty types in code without commenting inside why they are needed.",
    regex: #"(class|protocol|struct|enum) [^\{]+\{\s*\}"#,
    matchingExamples: ["class Foo {}", "enum Constants {\n    \n}", "struct MyViewModel(x: Int, y: Int, closure: () -> Void) {}"],
    nonMatchingExamples: ["class Foo { /* TODO: not yet implemented */ }", "func foo() {}", "init() {}", "enum Bar { case x, y }"],
    includeFilters: [swiftSourceFiles, swiftTestFiles]
)

// MARK: guard_multiline_2
try Lint.checkFileContents(
    checkInfo: "guard_multiline_2: Close a multiline guard via `else {` on a new line indented like the opening `guard`.",
    regex: [
        "newline": #"\n"#,
        "guardIndent": #" *"#,
        "guard": #"guard *"#,
        "line1": #"[^\n]+,"#,
        "line1Indent": #"\n *"#,
        "line2": #"[^\n]*\S"#,
        "else": #"\s*else\s*\{\s*"#
    ],
    matchingExamples: [
        """

            guard let x1 = y1?.imagePath,
                let z = EnumType(rawValue: 15) else {
                return 2
            }
        """
    ],
    nonMatchingExamples: [
        """

            guard
                let x1 = y1?.imagePath,
                let z = EnumType(rawValue: 15)
            else {
                return 2
            }
        """,
        """

            guard let url = URL(string: self, relativeTo: fileManager.currentDirectoryUrl) else {
                return 2
            }
        """,
    ],
    includeFilters: [swiftSourceFiles, swiftTestFiles],
    autoCorrectReplacement: """

        $guardIndentguard
        $guardIndent    $line1
        $guardIndent    $line2
        $guardIndentelse {
        $guardIndent\u{0020}\u{0020}\u{0020}\u{0020}
        """,
    autoCorrectExamples: [
        AutoCorrection(
            before: """
                    let x = 15
                    guard let x1 = y1?.imagePath,
                        let z = EnumType(rawValue: 15) else {
                        return 2
                    }
            """,
            after: """
                    let x = 15
                    guard
                        let x1 = y1?.imagePath,
                        let z = EnumType(rawValue: 15)
                    else {
                        return 2
                    }
            """
        ),
    ]
)

// MARK: guard_multiline_3
try Lint.checkFileContents(
    checkInfo: "guard_multiline_3: Close a multiline guard via `else {` on a new line indented like the opening `guard`.",
    regex: [
        "newline": #"\n"#,
        "guardIndent": #" *"#,
        "guard": #"guard *"#,
        "line1": #"[^\n]+,"#,
        "line1Indent": #"\n *"#,
        "line2": #"[^\n]+,"#,
        "line2Indent": #"\n *"#,
        "line3": #"[^\n]*\S"#,
        "else": #"\s*else\s*\{\s*"#
    ],
    matchingExamples: [
        """

            guard let x1 = y1?.imagePath,
                let x2 = y2?.imagePath,
                let z = EnumType(rawValue: 15) else {
                return 2
            }
        """
    ],
    nonMatchingExamples: [
        """

            guard
                let x1 = y1?.imagePath,
                let x2 = y2?.imagePath,
                let z = EnumType(rawValue: 15)
            else {
                return 2
            }
        """,
        """

            guard let url = URL(x: 1, y: 2, relativeTo: fileManager.currentDirectoryUrl) else {
                return 2
            }
        """,
    ],
    includeFilters: [swiftSourceFiles, swiftTestFiles],
    autoCorrectReplacement: """

        $guardIndentguard
        $guardIndent    $line1
        $guardIndent    $line2
        $guardIndent    $line3
        $guardIndentelse {
        $guardIndent\u{0020}\u{0020}\u{0020}\u{0020}
        """,
    autoCorrectExamples: [
        AutoCorrection(
            before: """
                    let x = 15
                    guard let x1 = y1?.imagePath,
                        let x2 = y2?.imagePath,
                        let z = EnumType(rawValue: 15) else {
                        return 2
                    }
            """,
            after: """
                    let x = 15
                    guard
                        let x1 = y1?.imagePath,
                        let x2 = y2?.imagePath,
                        let z = EnumType(rawValue: 15)
                    else {
                        return 2
                    }
            """
        ),
    ]
)

// MARK: guard_multiline_4
try Lint.checkFileContents(
    checkInfo: "guard_multiline_4: Close a multiline guard via `else {` on a new line indented like the opening `guard`.",
    regex: [
        "newline": #"\n"#,
        "guardIndent": #" *"#,
        "guard": #"guard *"#,
        "line1": #"[^\n]+,"#,
        "line1Indent": #"\n *"#,
        "line2": #"[^\n]+,"#,
        "line2Indent": #"\n *"#,
        "line3": #"[^\n]+,"#,
        "line3Indent": #"\n *"#,
        "line4": #"[^\n]*\S"#,
        "else": #"\s*else\s*\{\s*"#
    ],
    matchingExamples: [
        """

            guard let x1 = y1?.imagePath,
                let x2 = y2?.imagePath,
                let x3 = y3?.imagePath,
                let z = EnumType(rawValue: 15) else {
                return 2
            }
        """
    ],
    nonMatchingExamples: [
        """

            guard
                let x1 = y1?.imagePath,
                let x2 = y2?.imagePath,
                let x3 = y3?.imagePath,
                let z = EnumType(rawValue: 15)
            else {
                return 2
            }
        """,
        """

            guard let url = URL(x: 1, y: 2, z: 3, relativeTo: fileManager.currentDirectoryUrl) else {
                return 2
            }
        """,
    ],
    includeFilters: [swiftSourceFiles, swiftTestFiles],
    autoCorrectReplacement: """

        $guardIndentguard
        $guardIndent    $line1
        $guardIndent    $line2
        $guardIndent    $line3
        $guardIndent    $line4
        $guardIndentelse {
        $guardIndent\u{0020}\u{0020}\u{0020}\u{0020}
        """,
    autoCorrectExamples: [
        AutoCorrection(
            before: """
                    let x = 15
                    guard let x1 = y1?.imagePath,
                        let x2 = y2?.imagePath,
                        let x3 = y3?.imagePath,
                        let z = EnumType(rawValue: 15) else {
                        return 2
                    }
            """,
            after: """
                    let x = 15
                    guard
                        let x1 = y1?.imagePath,
                        let x2 = y2?.imagePath,
                        let x3 = y3?.imagePath,
                        let z = EnumType(rawValue: 15)
                    else {
                        return 2
                    }
            """
        ),
    ]
)

// MARK: guard_multiline_n
try Lint.checkFileContents(
    checkInfo: "guard_multiline_n: Close a multiline guard via `else {` on a new line indented like the opening `guard`.",
    regex: #"\n *guard *([^\n]+,\n){4,}[^\n]*\S\s*else\s*\{\s*"#,
    matchingExamples: [
        """

            guard let x1 = y1?.imagePath,
                let x2 = y2?.imagePath,
                let x3 = y3?.imagePath,
                let x4 = y4?.imagePath,
                let x5 = y5?.imagePath,
                let z = EnumType(rawValue: 15) else {
                return 2
            }
        """
    ],
    nonMatchingExamples: [
        """

            guard
                let x1 = y1?.imagePath,
                let x2 = y2?.imagePath,
                let x3 = y3?.imagePath,
                let x4 = y4?.imagePath,
                let x5 = y5?.imagePath,
                let z = EnumType(rawValue: 15)
            else {
                return 2
            }
        """,
        """

            guard let url = URL(x1: 1, x2: 2, x3: 3, x4: 4, x5: 5, relativeTo: fileManager.currentDirectoryUrl) else {
                return 2
            }
        """,
    ],
    includeFilters: [swiftSourceFiles, swiftTestFiles]
)

// MARK: if_as_guard
try Lint.checkFileContents(
    checkInfo: "if_as_guard: Don't use an if statement to just return – use guard for such cases instead.",
    regex: #" +if [^\{]+\{\s*return\s*[^\}]*\}(?! *else)"#,
    matchingExamples: [" if x == 5 { return }", " if x == 5 {\n    return nil\n}", " if x == 5 { return 500 }", " if x == 5 { return do(x: 500, y: 200) }"],
    nonMatchingExamples: [" if x == 5 {\n    let y = 200\n    return y\n}", " if x == 5 { someMethod(x: 500, y: 200) }", " if x == 500 { return } else {"],
    includeFilters: [swiftSourceFiles, swiftTestFiles]
)

// MARK: late_force_unwrapping_3
try Lint.checkFileContents(
    checkInfo: "late_force_unwrapping_3: Don't use ? first to force unwrap later – directly unwrap within the parantheses.",
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

// MARK: late_force_unwrapping_2
try Lint.checkFileContents(
    checkInfo: "late_force_unwrapping_2: Don't use ? first to force unwrap later – directly unwrap within the parantheses.",
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

// MARK: late_force_unwrapping_1
try Lint.checkFileContents(
    checkInfo: "late_force_unwrapping_1: Don't use ? first to force unwrap later – directly unwrap within the parantheses.",
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

// MARK: logger
try Lint.checkFileContents(
    checkInfo: "logger: Don't use `print` – use `log.message` instead.",
    regex: #"print\([^\n]+\)"#,
    matchingExamples: [#"print("Hellow World!")"#, #"print(5)"#, #"print(\n    "hi"\n)"#],
    nonMatchingExamples: [#"log.message("Hello world!")"#],
    includeFilters: [swiftSourceFiles, swiftTestFiles],
    excludeFilters: [#"Sources/.*/Logger\.swift"#]
)

// MARK: readme
try Lint.checkFilePaths(
    checkInfo: "readme: Each project should have a README.md file, explaining how to use or contribute to the project.",
    regex: #"^README\.md$"#,
    matchingExamples: ["README.md"],
    nonMatchingExamples: ["README.markdown", "Readme.md", "ReadMe.md"],
    violateIfNoMatchesFound: true
)

// MARK: readme_path
try Lint.checkFilePaths(
    checkInfo: "readme_path: The README file should be named exactly `README.md`.",
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

// MARK: readme_top_level_title
try Lint.checkFileContents(
    checkInfo: "readme_top_level_title: The README.md file should only contain a single top level title.",
    regex: #"(^|\n)#[^#](.*\n)*\n#[^#]"#,
    matchingExamples: [
        """
        # Title
        ## Subtitle
        Lorem ipsum

        # Other Title
        ## Other Subtitle
        """,
    ],
    nonMatchingExamples: [
        """
        # Title
        ## Subtitle
        Lorem ipsum #1 and # 2.

        ## Other Subtitle
        ### Other Subsubtitle
        """,
    ],
    includeFilters: [readmeFile]
)

// MARK: readme_typo_license
try Lint.checkFileContents(
    checkInfo: "readme_typo_license: Misspelled word 'license'.",
    regex: #"([\s#]L|l)isence([\s\.,:;])"#,
    matchingExamples: [" lisence:", "## Lisence\n"],
    nonMatchingExamples: [" license:", "## License\n"],
    includeFilters: [readmeFile],
    autoCorrectReplacement: "$1icense$2",
    autoCorrectExamples: [
        AutoCorrection(before: " lisence:", after: " license:"),
        AutoCorrection(before: "## Lisence\n", after: "## License\n"),
    ]
)

// MARK: - Log Summary & Exit
Lint.logSummaryAndExit()
