#!/usr/local/bin/swift-sh
import AnyLint // .

try Lint.logSummaryAndExit(arguments: CommandLine.arguments) {
    // MARK: - Variables
    let swiftSourceFiles: Regex = #"Sources/.*\.swift"#
    let swiftTestFiles: Regex = #"Tests/.*\.swift"#
    let readmeFile: Regex = #"README\.md"#
    let changelogFile: Regex = #"^CHANGELOG\.md$"#

    // MARK: - Checks
    // MARK: Changelog
    try Lint.checkFilePaths(
        checkInfo: "Changelog: Each project should have a CHANGELOG.md file, tracking the changes within a project over time.",
        regex: changelogFile,
        matchingExamples: ["CHANGELOG.md"],
        nonMatchingExamples: ["CHANGELOG.markdown", "Changelog.md", "ChangeLog.md"],
        violateIfNoMatchesFound: true
    )

    // MARK: ChangelogEntryTrailingWhitespaces
    try Lint.checkFileContents(
        checkInfo: "ChangelogEntryTrailingWhitespaces: The summary line of a Changelog entry should end with two whitespaces.",
        regex: #"\n([-–] (?!None\.).*[^ ])( {0,1}| {3,})\n"#,
        matchingExamples: ["\n- Fixed a bug.\n  Issue:", "\n- Added a new option. (see [Link](#)) \nPR:"],
        nonMatchingExamples: ["\n- Fixed a bug.  \n  Issue:", "\n- Added a new option. (see [Link](#))  \nPR:"],
        includeFilters: [changelogFile],
        autoCorrectReplacement: "\n$1  \n",
        autoCorrectExamples: [
            ["before": "\n- Fixed a bug.\n  Issue:", "after": "\n- Fixed a bug.  \n  Issue:"],
            ["before": "\n- Fixed a bug. \n  Issue:", "after": "\n- Fixed a bug.  \n  Issue:"],
            ["before": "\n- Fixed a bug.   \n  Issue:", "after": "\n- Fixed a bug.  \n  Issue:"],
            ["before": "\n- Fixed a bug !\n  Issue:", "after": "\n- Fixed a bug !  \n  Issue:"],
            ["before": "\n- Fixed a bug ! \n  Issue:", "after": "\n- Fixed a bug !  \n  Issue:"],
            ["before": "\n- Fixed a bug !  \n  Issue:", "after": "\n- Fixed a bug !  \n  Issue:"],
        ]
    )

    // MARK: ChangelogEntryLeadingWhitespaces
    try Lint.checkFileContents(
        checkInfo: "ChangelogEntryLeadingWhitespaces: The links line of a Changelog entry should start with two whitespaces.",
        regex: #"\n( {0,1}| {3,})(Tasks?:|Issues?:|PRs?:|Authors?:)"#,
        matchingExamples: ["\n- Fixed a bug.\nIssue: [Link](#)", "\n- Fixed a bug. \nIssue: [Link](#)", "\n- Fixed a bug.    \nIssue: [Link](#)"],
        nonMatchingExamples: ["- Fixed a bug.\n  Issue: [Link](#)"],
        includeFilters: [changelogFile],
        autoCorrectReplacement: "\n  $2",
        autoCorrectExamples: [
            ["before": "\n- Fixed a bug.\nIssue: [Link](#)", "after": "\n- Fixed a bug.\n  Issue: [Link](#)"],
            ["before": "\n- Fixed a bug.\n Issue: [Link](#)", "after": "\n- Fixed a bug.\n  Issue: [Link](#)"],
            ["before": "\n- Fixed a bug.\n    Issue: [Link](#)", "after": "\n- Fixed a bug.\n  Issue: [Link](#)"],
        ]
    )

    // MARK: EmptyMethodBody
    try Lint.checkFileContents(
        checkInfo: "EmptyMethodBody: Don't use whitespace or newlines for the body of empty methods.",
        regex: ["declaration": #"(init|func [^\(\s]+)\([^{}]*\)"#, "spacing": #"\s*"#, "body": #"\{\s+\}"#],
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
            ["before": "init()  { }", "after": "init() {}"],
            ["before": "init(x: Int, y: Int)  { }", "after": "init(x: Int, y: Int) {}"],
            ["before": "init()\n{\n    \n}", "after": "init() {}"],
            ["before": "init(\n    x: Int,\n    y: Int\n) {\n    \n}", "after": "init(\n    x: Int,\n    y: Int\n) {}"],
            ["before": "func foo2bar()  { }", "after": "func foo2bar() {}"],
            ["before": "func foo2bar(x: Int, y: Int)  { }", "after": "func foo2bar(x: Int, y: Int) {}"],
            ["before": "func foo2bar()\n{\n    \n}", "after": "func foo2bar() {}"],
            ["before": "func foo2bar(\n    x: Int,\n    y: Int\n) {\n    \n}", "after": "func foo2bar(\n    x: Int,\n    y: Int\n) {}"],
        ]
    )

    // MARK: EmptyTodo
    try Lint.checkFileContents(
        checkInfo: "EmptyTodo: `// TODO:` comments should not be empty.",
        regex: #"// TODO: ?(\[[\d\-_a-z]+\])? *\n"#,
        matchingExamples: ["// TODO:\n", "// TODO: [2020-03-19]\n", "// TODO: [cg_2020-03-19]  \n"],
        nonMatchingExamples: ["// TODO: refactor", "// TODO: not yet implemented", "// TODO: [cg_2020-03-19] not yet implemented"],
        includeFilters: [swiftSourceFiles, swiftTestFiles]
    )

    // MARK: EmptyType
    try Lint.checkFileContents(
        checkInfo: "EmptyType: Don't keep empty types in code without commenting inside why they are needed.",
        regex: #"(class|protocol|struct|enum) [^\{]+\{\s*\}"#,
        matchingExamples: ["class Foo {}", "enum Constants {\n    \n}", "struct MyViewModel(x: Int, y: Int, closure: () -> Void) {}"],
        nonMatchingExamples: ["class Foo { /* TODO: not yet implemented */ }", "func foo() {}", "init() {}", "enum Bar { case x, y }"],
        includeFilters: [swiftSourceFiles, swiftTestFiles]
    )

    // MARK: GuardMultiline2
    try Lint.checkFileContents(
        checkInfo: "GuardMultiline2: Close a multiline guard via `else {` on a new line indented like the opening `guard`.",
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
            [
                "before": """
                        let x = 15
                        guard let x1 = y1?.imagePath,
                            let z = EnumType(rawValue: 15) else {
                            return 2
                        }
                """,
                "after": """
                        let x = 15
                        guard
                            let x1 = y1?.imagePath,
                            let z = EnumType(rawValue: 15)
                        else {
                            return 2
                        }
                """
            ],
        ]
    )

    // MARK: GuardMultiline3
    try Lint.checkFileContents(
        checkInfo: "GuardMultiline3: Close a multiline guard via `else {` on a new line indented like the opening `guard`.",
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
            [
                "before": """
                        let x = 15
                        guard let x1 = y1?.imagePath,
                            let x2 = y2?.imagePath,
                            let z = EnumType(rawValue: 15) else {
                            return 2
                        }
                """,
                "after": """
                        let x = 15
                        guard
                            let x1 = y1?.imagePath,
                            let x2 = y2?.imagePath,
                            let z = EnumType(rawValue: 15)
                        else {
                            return 2
                        }
                """
            ],
        ]
    )

    // MARK: GuardMultiline4
    try Lint.checkFileContents(
        checkInfo: "GuardMultiline4: Close a multiline guard via `else {` on a new line indented like the opening `guard`.",
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
            [
                "before": """
                        let x = 15
                        guard let x1 = y1?.imagePath,
                            let x2 = y2?.imagePath,
                            let x3 = y3?.imagePath,
                            let z = EnumType(rawValue: 15) else {
                            return 2
                        }
                """,
                "after": """
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
            ],
        ]
    )

    // MARK: GuardMultilineN
    try Lint.checkFileContents(
        checkInfo: "GuardMultilineN: Close a multiline guard via `else {` on a new line indented like the opening `guard`.",
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

    // MARK: IfAsGuard
    try Lint.checkFileContents(
        checkInfo: "IfAsGuard: Don't use an if statement to just return – use guard for such cases instead.",
        regex: #" +if [^\{]+\{\s*return\s*[^\}]*\}(?! *else)"#,
        matchingExamples: [" if x == 5 { return }", " if x == 5 {\n    return nil\n}", " if x == 5 { return 500 }", " if x == 5 { return do(x: 500, y: 200) }"],
        nonMatchingExamples: [" if x == 5 {\n    let y = 200\n    return y\n}", " if x == 5 { someMethod(x: 500, y: 200) }", " if x == 500 { return } else {"],
        includeFilters: [swiftSourceFiles, swiftTestFiles]
    )

    // MARK: LateForceUnwrapping3
    try Lint.checkFileContents(
        checkInfo: "LateForceUnwrapping3: Don't use ? first to force unwrap later – directly unwrap within the parantheses.",
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
            ["before": "let x = (viewModel?.user?.profile?.imagePath)!\n", "after": "let x = viewModel!.user!.profile!.imagePath\n"],
        ]
    )

    // MARK: LateForceUnwrapping2
    try Lint.checkFileContents(
        checkInfo: "LateForceUnwrapping2: Don't use ? first to force unwrap later – directly unwrap within the parantheses.",
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
            ["before": "let x = (viewModel?.profile?.imagePath)!\n", "after": "let x = viewModel!.profile!.imagePath\n"],
        ]
    )

    // MARK: LateForceUnwrapping1
    try Lint.checkFileContents(
        checkInfo: "LateForceUnwrapping1: Don't use ? first to force unwrap later – directly unwrap within the parantheses.",
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
            ["before": "call(x: (viewModel?.username)!)", "after": "call(x: viewModel!.username)"],
        ]
    )

    // MARK: Logger
    try Lint.checkFileContents(
        checkInfo: "Logger: Don't use `print` – use `log.message` instead.",
        regex: #"print\([^\n]+\)"#,
        matchingExamples: [#"print("Hellow World!")"#, #"print(5)"#, #"print(\n    "hi"\n)"#],
        nonMatchingExamples: [#"log.message("Hello world!")"#],
        includeFilters: [swiftSourceFiles, swiftTestFiles],
        excludeFilters: [#"Sources/.*/Logger\.swift"#]
    )

    // MARK: Readme
    try Lint.checkFilePaths(
        checkInfo: "Readme: Each project should have a README.md file, explaining how to use or contribute to the project.",
        regex: #"^README\.md$"#,
        matchingExamples: ["README.md"],
        nonMatchingExamples: ["README.markdown", "Readme.md", "ReadMe.md"],
        violateIfNoMatchesFound: true
    )

    // MARK: ReadmePath
    try Lint.checkFilePaths(
        checkInfo: "ReadmePath: The README file should be named exactly `README.md`.",
        regex: #"^(.*/)?([Rr][Ee][Aa][Dd][Mm][Ee]\.markdown|readme\.md|Readme\.md|ReadMe\.md)$"#,
        matchingExamples: ["README.markdown", "readme.md", "ReadMe.md"],
        nonMatchingExamples: ["README.md", "CHANGELOG.md", "CONTRIBUTING.md", "api/help.md"],
        autoCorrectReplacement: "$1README.md",
        autoCorrectExamples: [
            ["before": "api/readme.md", "after": "api/README.md"],
            ["before": "ReadMe.md", "after": "README.md"],
            ["before": "README.markdown", "after": "README.md"],
        ]
    )
}
