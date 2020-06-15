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
                    subpath: "AnyLint/Sample.swift",
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
            XCTAssertEqual(TestHelper.shared.consoleOutputs[0].message, "Running local config file at '\(filePaths[0])'")
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
            "Running local config file at '\(Constants.tempDirPath)/Flinesoft_AnyLint_Variants_Sample.swift'"
        )
        XCTAssertEqual(TestHelper.shared.consoleOutputs[0].level, .info)
        XCTAssert(FileManager.default.fileExists(atPath: "\(Constants.tempDirPath)/Flinesoft_AnyLint_Variants_Sample.swift"))

        let check: CheckInfo = "PseudoCheck: Checks if the file `Pseudo.md` exists."
        XCTAssert(violations.keys.contains(check))
        XCTAssertEqual(violations[check]!.count, 1)
    }

    func testPerformWithGithubSource() {
        let violations = try! TemplateChecker(
            source: .github(
                repo: "Flinesoft/AnyLint",
                version: "wip/cg_template-system",
                variant: "Tests/Variants/sample"
            ),
            runOnly: nil,
            exclude: nil,
            logDebugLevel: false
        ).performCheck()

        XCTAssertEqual(TestHelper.shared.consoleOutputs.count, 1)
        XCTAssertEqual(
            TestHelper.shared.consoleOutputs[0].message,
            "Running local config file at '\(Constants.tempDirPath)/Flinesoft_AnyLint_Variants_Sample.swift'"
        )
        XCTAssertEqual(TestHelper.shared.consoleOutputs[0].level, .info)
        XCTAssert(FileManager.default.fileExists(atPath: "\(Constants.tempDirPath)/Flinesoft_AnyLint_Variants_Sample.swift"))

        let check: CheckInfo = "PseudoCheck: Checks if the file `Pseudo.md` exists."
        XCTAssert(violations.keys.contains(check))
        XCTAssertEqual(violations[check]!.count, 1)
    }
}
