@testable import AnyLint
@testable import Utility
import XCTest

final class FileContentsCheckerTests: XCTestCase {
    override func setUp() {
        log = Logger(outputType: .test)
        TestHelper.shared.reset()
    }

    func testPerformCheck() {
        let temporaryFiles: [TemporaryFile] = [
            (subpath: "Sources/Hello.swift", contents: "let x = 5\nvar y = 10"),
            (subpath: "Sources/World.swift", contents: "let x=5\nvar y=10"),
        ]

        withTemporaryFiles(temporaryFiles) { filePathsToCheck in
            let checkInfo = CheckInfo(id: "whitespacing", hint: "Always add a single whitespace around '='.", severity: .warning)
            let violations = try FileContentsChecker(
                checkInfo: checkInfo,
                regex: #"(let|var) \w+=\w+"#,
                filePathsToCheck: filePathsToCheck,
                autoCorrectReplacement: nil
            ).performCheck()

            XCTAssertEqual(violations.count, 2)

            XCTAssertEqual(violations[0].checkInfo, checkInfo)
            XCTAssertEqual(violations[0].filePath, "\(tempDir)/Sources/World.swift")
            XCTAssertEqual(violations[0].locationInfo!.line, 1)
            XCTAssertEqual(violations[0].locationInfo!.charInLine, 1)

            XCTAssertEqual(violations[1].checkInfo, checkInfo)
            XCTAssertEqual(violations[1].filePath, "\(tempDir)/Sources/World.swift")
            XCTAssertEqual(violations[1].locationInfo!.line, 2)
            XCTAssertEqual(violations[1].locationInfo!.charInLine, 1)
        }
    }
}
