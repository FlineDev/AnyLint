@testable import AnyLint
@testable import Utility
import XCTest

final class FilePathsCheckerTests: XCTestCase {
    override func setUp() {
        log = Logger(outputType: .test)
        TestHelper.shared.reset()
    }

    func testPerformCheck() {
        withTemporaryFiles(
            [
                (subpath: "Sources/Hello.swift", contents: ""),
                (subpath: "Sources/World.swift", contents: ""),
            ]
        ) { filePathsToCheck in
            let violations = try sayHelloChecker(filePathsToCheck: filePathsToCheck).performCheck()[sayHelloCheck()]!
            XCTAssertEqual(violations.count, 0)
        }

        withTemporaryFiles([(subpath: "Sources/World.swift", contents: "")]) { filePathsToCheck in
            let violations = try sayHelloChecker(filePathsToCheck: filePathsToCheck).performCheck()[sayHelloCheck()]!

            XCTAssertEqual(violations.count, 1)

            XCTAssertEqual(violations[0].checkInfo, sayHelloCheck())
            XCTAssertNil(violations[0].filePath)
            XCTAssertNil(violations[0].locationInfo)
            XCTAssertNil(violations[0].locationInfo)
        }

        withTemporaryFiles(
            [
                (subpath: "Sources/Hello.swift", contents: ""),
                (subpath: "Sources/World.swift", contents: ""),
            ]
        ) { filePathsToCheck in
            let violations = try noWorldChecker(filePathsToCheck: filePathsToCheck).performCheck()[noWorldCheck()]!

            XCTAssertEqual(violations.count, 1)

            XCTAssertEqual(violations[0].checkInfo, noWorldCheck())
            XCTAssertEqual(violations[0].filePath, "\(tempDir)/Sources/World.swift")
            XCTAssertNil(violations[0].locationInfo)
            XCTAssertNil(violations[0].locationInfo)
        }
    }

    private func sayHelloChecker(filePathsToCheck: [String]) -> FilePathsChecker {
        FilePathsChecker(
            checkInfo: sayHelloCheck(),
            regex: #".*Hello\.swift"#,
            filePathsToCheck: filePathsToCheck,
            autoCorrectReplacement: nil,
            violateIfNoMatchesFound: true
        )
    }

    private func sayHelloCheck() -> CheckInfo {
        CheckInfo(id: "say_hello", hint: "Should always say hello.", severity: .info)
    }

    private func noWorldChecker(filePathsToCheck: [String]) -> FilePathsChecker {
        FilePathsChecker(
            checkInfo: noWorldCheck(),
            regex: #".*World\.swift"#,
            filePathsToCheck: filePathsToCheck,
            autoCorrectReplacement: nil,
            violateIfNoMatchesFound: false
        )
    }

    private func noWorldCheck() -> CheckInfo {
        CheckInfo(id: "no_world", hint: "Do not include the global world, be more specific instead.", severity: .error)
    }
}
