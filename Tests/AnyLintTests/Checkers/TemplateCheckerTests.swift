@testable import AnyLint
@testable import Utility
import XCTest

final class TemplateCheckerTests: XCTestCase {
    override func setUp() {
        log = Logger(outputType: .test)
        TestHelper.shared.reset()
    }

    func testPerformWithLocalSource() {
        withTemporaryFiles([(subpath: "AnyLint/sample.swift", contents: "")]) { filePaths in
            _ = try! TemplateChecker(source: .local(filePaths[0]), runOnly: nil, exclude: nil).performCheck()
            XCTAssertEqual(TestHelper.shared.consoleOutputs.count, 1)
            XCTAssertEqual(TestHelper.shared.consoleOutputs[0].message, "Local template file to run: '\(filePaths[0])'")
            XCTAssertEqual(TestHelper.shared.consoleOutputs[0].level, .info)
        }
    }

    func testPerformWithRemoteSource() {
        _ = try! TemplateChecker(
            source: .remote("https://raw.githubusercontent.com/Flinesoft/AnyLint-Swift/main/Variants/sample.swift"),
            runOnly: nil,
            exclude: nil
        ).performCheck()

        XCTAssertEqual(TestHelper.shared.consoleOutputs.count, 1)
        XCTAssertEqual(
            TestHelper.shared.consoleOutputs[0].message,
            "Local template file to run: '\(Constants.tempDirPath)/Flinesoft_AnyLint-Swift_main_sample.swift'"
        )
        XCTAssertEqual(TestHelper.shared.consoleOutputs[0].level, .info)
        XCTAssert(FileManager.default.fileExists(atPath: "\(Constants.tempDirPath)/Flinesoft_AnyLint-Swift_main_sample.swift"))
    }

    func testPerformWithGithubSource() {
        _ = try! TemplateChecker(
            source: .github(user: "Flinesoft", repo: "AnyLint-Swift", branchOrTag: "main", variant: "sample"),
            runOnly: nil,
            exclude: nil
        ).performCheck()

        XCTAssertEqual(TestHelper.shared.consoleOutputs.count, 1)
        XCTAssertEqual(
            TestHelper.shared.consoleOutputs[0].message,
            "Local template file to run: '\(Constants.tempDirPath)/Flinesoft_AnyLint-Swift_main_sample.swift'"
        )
        XCTAssertEqual(TestHelper.shared.consoleOutputs[0].level, .info)
        XCTAssert(FileManager.default.fileExists(atPath: "\(Constants.tempDirPath)/Flinesoft_AnyLint-Swift_main_sample.swift"))
    }
}
