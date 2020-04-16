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
            let checkInfo = CheckInfo(id: "Whitespacing", hint: "Always add a single whitespace around '='.", severity: .warning)
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

    func testSkipInFile() {
        let temporaryFiles: [TemporaryFile] = [
            (subpath: "Sources/Hello.swift", contents: "// AnyLint.skipInFile: OtherRule, Whitespacing\n\n\nlet x=5\nvar y=10"),
            (subpath: "Sources/World.swift", contents: "// AnyLint.skipInFile: All\n\n\nlet x=5\nvar y=10"),
            (subpath: "Sources/Foo.swift", contents: "// AnyLint.skipInFile: OtherRule\n\n\nlet x=5\nvar y=10"),
        ]

        withTemporaryFiles(temporaryFiles) { filePathsToCheck in
            let checkInfo = CheckInfo(id: "Whitespacing", hint: "Always add a single whitespace around '='.", severity: .warning)
            let violations = try FileContentsChecker(
                checkInfo: checkInfo,
                regex: #"(let|var) \w+=\w+"#,
                filePathsToCheck: filePathsToCheck,
                autoCorrectReplacement: nil
            ).performCheck()

            XCTAssertEqual(violations.count, 2)

            XCTAssertEqual(violations[0].checkInfo, checkInfo)
            XCTAssertEqual(violations[0].filePath, "\(tempDir)/Sources/Foo.swift")
            XCTAssertEqual(violations[0].locationInfo!.line, 4)
            XCTAssertEqual(violations[0].locationInfo!.charInLine, 1)

            XCTAssertEqual(violations[1].checkInfo, checkInfo)
            XCTAssertEqual(violations[1].filePath, "\(tempDir)/Sources/Foo.swift")
            XCTAssertEqual(violations[1].locationInfo!.line, 5)
            XCTAssertEqual(violations[1].locationInfo!.charInLine, 1)
        }
    }

    func testSkipHere() {
        let temporaryFiles: [TemporaryFile] = [
            (subpath: "Sources/Hello.swift", contents: "// AnyLint.skipHere: OtherRule, Whitespacing\n\n\nlet x=5\nvar y=10"),
            (subpath: "Sources/World.swift", contents: "\n\n// AnyLint.skipHere: OtherRule, Whitespacing\nlet x=5\nvar y=10"),
            (subpath: "Sources/Foo.swift", contents: "\n\n\nlet x=5\nvar y=10 // AnyLint.skipHere: OtherRule, Whitespacing\n"),
            (subpath: "Sources/Bar.swift", contents: "\n\n\nlet x=5\nvar y=10\n// AnyLint.skipHere: OtherRule, Whitespacing"),
        ]

        withTemporaryFiles(temporaryFiles) { filePathsToCheck in
            let checkInfo = CheckInfo(id: "Whitespacing", hint: "Always add a single whitespace around '='.", severity: .warning)
            let violations = try FileContentsChecker(
                checkInfo: checkInfo,
                regex: #"(let|var) \w+=\w+"#,
                filePathsToCheck: filePathsToCheck,
                autoCorrectReplacement: nil
            ).performCheck()

            XCTAssertEqual(violations.count, 6)

            XCTAssertEqual(violations[0].checkInfo, checkInfo)
            XCTAssertEqual(violations[0].filePath, "\(tempDir)/Sources/Hello.swift")
            XCTAssertEqual(violations[0].locationInfo!.line, 4)
            XCTAssertEqual(violations[0].locationInfo!.charInLine, 1)

            XCTAssertEqual(violations[1].checkInfo, checkInfo)
            XCTAssertEqual(violations[1].filePath, "\(tempDir)/Sources/Hello.swift")
            XCTAssertEqual(violations[1].locationInfo!.line, 5)
            XCTAssertEqual(violations[1].locationInfo!.charInLine, 1)

            XCTAssertEqual(violations[2].checkInfo, checkInfo)
            XCTAssertEqual(violations[2].filePath, "\(tempDir)/Sources/World.swift")
            XCTAssertEqual(violations[2].locationInfo!.line, 5)
            XCTAssertEqual(violations[2].locationInfo!.charInLine, 1)

            XCTAssertEqual(violations[3].checkInfo, checkInfo)
            XCTAssertEqual(violations[3].filePath, "\(tempDir)/Sources/Foo.swift")
            XCTAssertEqual(violations[3].locationInfo!.line, 4)
            XCTAssertEqual(violations[3].locationInfo!.charInLine, 1)

            XCTAssertEqual(violations[4].checkInfo, checkInfo)
            XCTAssertEqual(violations[4].filePath, "\(tempDir)/Sources/Bar.swift")
            XCTAssertEqual(violations[4].locationInfo!.line, 4)
            XCTAssertEqual(violations[4].locationInfo!.charInLine, 1)

            XCTAssertEqual(violations[5].checkInfo, checkInfo)
            XCTAssertEqual(violations[5].filePath, "\(tempDir)/Sources/Bar.swift")
            XCTAssertEqual(violations[5].locationInfo!.line, 5)
            XCTAssertEqual(violations[5].locationInfo!.charInLine, 1)
        }
    }
}
