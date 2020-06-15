@testable import AnyLint
@testable import Utility
import XCTest

final class TemplateCheckerTests: XCTestCase {
    override func setUp() {
        log = Logger(outputType: .test)
        TestHelper.shared.reset()
    }

    func testPerformWithLocalSource() {
        withTemporaryFiles(
            [
                (
                    subpath: "AnyLint/sample.swift",
                    contents: """
                        #!/usr/local/bin/swift-sh
                        import AnyLint // @Flinesoft == wip/cg_template-system

                        try Lint.reportResultsToFile(arguments: CommandLine.arguments) {
                            // MARK: PseudoCheck
                            try Lint.checkFilePaths(
                                checkInfo: "PseudoCheck: Checks if the file `Pseudo.md` exists.",
                                regex: #"^Pseudo\\.md$"#,
                                matchingExamples: ["Pseudo.md"],
                                nonMatchingExamples: ["Pseudo.markdown", "PSEUDO.md"],
                                violateIfNoMatchesFound: true
                            )
                        }

                        """
                ),
            ]
        ) { filePaths in
            let violations = try! TemplateChecker(source: .local(filePaths[0]), runOnly: nil, exclude: nil, logDebugLevel: false).performCheck()
            XCTAssertEqual(TestHelper.shared.consoleOutputs.count, 1)
            XCTAssertEqual(TestHelper.shared.consoleOutputs[0].message, "Local template file to run: '\(filePaths[0])'")
            XCTAssertEqual(TestHelper.shared.consoleOutputs[0].level, .info)

            let check: CheckInfo = "PseudoCheck: Checks if the file `Pseudo.md` exists."
            XCTAssert(violations.keys.contains(check))
            XCTAssertEqual(violations[check]!.count, 1)
        }
    }

    func testPerformWithRemoteSource() {
        let violations = try! TemplateChecker(
            source: .remote("https://raw.githubusercontent.com/Flinesoft/AnyLint/wip/cg_template-system/Tests/Variants/sample.swift"),
            runOnly: nil,
            exclude: nil,
            logDebugLevel: false
        ).performCheck()

        XCTAssertEqual(TestHelper.shared.consoleOutputs.count, 1)
        XCTAssertEqual(
            TestHelper.shared.consoleOutputs[0].message,
            "Local template file to run: '\(Constants.tempDirPath)/Flinesoft_AnyLint_sample.swift'"
        )
        XCTAssertEqual(TestHelper.shared.consoleOutputs[0].level, .info)
        XCTAssert(FileManager.default.fileExists(atPath: "\(Constants.tempDirPath)/Flinesoft_AnyLint_sample.swift"))

        let check: CheckInfo = "PseudoCheck: Checks if the file `Pseudo.md` exists."
        XCTAssert(violations.keys.contains(check))
        XCTAssertEqual(violations[check]!.count, 1)
    }

    func testPerformWithGithubSource() {
        let violations = try! TemplateChecker(
            source: .github(
                user: "Flinesoft",
                repo: "AnyLint",
                branchOrTag: "wip/cg_template-system",
                subpath: "Tests/Variants",
                variant: "sample"
            ),
            runOnly: nil,
            exclude: nil,
            logDebugLevel: false
        ).performCheck()

        XCTAssertEqual(TestHelper.shared.consoleOutputs.count, 1)
        XCTAssertEqual(
            TestHelper.shared.consoleOutputs[0].message,
            "Local template file to run: '\(Constants.tempDirPath)/Flinesoft_AnyLint_sample.swift'"
        )
        XCTAssertEqual(TestHelper.shared.consoleOutputs[0].level, .info)
        XCTAssert(FileManager.default.fileExists(atPath: "\(Constants.tempDirPath)/Flinesoft_AnyLint_sample.swift"))

        let check: CheckInfo = "PseudoCheck: Checks if the file `Pseudo.md` exists."
        XCTAssert(violations.keys.contains(check))
        XCTAssertEqual(violations[check]!.count, 1)
    }
}
