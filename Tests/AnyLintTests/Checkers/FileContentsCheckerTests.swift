@testable import AnyLint
@testable import Utility
import XCTest

// swiftlint:disable function_body_length

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
            violationLocation: .init(range: .fullMatch, bound: .lower),
            filePathsToCheck: filePathsToCheck,
            autoCorrectReplacement: nil,
            repeatIfAutoCorrected: false
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
            violationLocation: .init(range: .fullMatch, bound: .lower),
            filePathsToCheck: filePathsToCheck,
            autoCorrectReplacement: nil,
            repeatIfAutoCorrected: false
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
            violationLocation: .init(range: .fullMatch, bound: .lower),
            filePathsToCheck: filePathsToCheck,
            autoCorrectReplacement: nil,
            repeatIfAutoCorrected: false
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

   func testSkipIfEqualsToAutocorrectReplacement() {
      let temporaryFiles: [TemporaryFile] = [
         (subpath: "Sources/Hello.swift", contents: "let x = 5\nvar y = 10"),
         (subpath: "Sources/World.swift", contents: "let x =5\nvar y= 10"),
      ]

      withTemporaryFiles(temporaryFiles) { filePathsToCheck in
         let checkInfo = CheckInfo(id: "Whitespacing", hint: "Always add a single whitespace around '='.", severity: .warning)
         let violations = try FileContentsChecker(
            checkInfo: checkInfo,
            regex: #"(let|var) (\w+)\s*=\s*(\w+)"#,
            violationLocation: .init(range: .fullMatch, bound: .lower),
            filePathsToCheck: filePathsToCheck,
            autoCorrectReplacement: "$1 $2 = $3",
            repeatIfAutoCorrected: false
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

   func testRepeatIfAutoCorrected() {
      let temporaryFiles: [TemporaryFile] = [
         (subpath: "Sources/Hello.swift", contents: "let x = 500\nvar y = 10000"),
         (subpath: "Sources/World.swift", contents: "let x = 50000000\nvar y = 100000000000000"),
      ]

      withTemporaryFiles(temporaryFiles) { filePathsToCheck in
         let checkInfo = CheckInfo(id: "LongNumbers", hint: "Format long numbers with `_` after each triple of digits from the right.", severity: .warning)
         let violations = try FileContentsChecker(
            checkInfo: checkInfo,
            regex: #"(?<!\d)(\d+)(\d{3})(?!\d)"#,
            violationLocation: .init(range: .fullMatch, bound: .lower),
            filePathsToCheck: filePathsToCheck,
            autoCorrectReplacement: "$1_$2",
            repeatIfAutoCorrected: true
         ).performCheck()

         XCTAssertEqual(violations.count, 7)

         XCTAssertEqual(violations[0].checkInfo, checkInfo)
         XCTAssertEqual(violations[0].filePath, "\(tempDir)/Sources/Hello.swift")
         XCTAssertEqual(violations[0].locationInfo!.line, 2)
         XCTAssertEqual(violations[0].locationInfo!.charInLine, 9)
         XCTAssertEqual(violations[0].appliedAutoCorrection!.after, "10_000")

         XCTAssertEqual(violations[1].checkInfo, checkInfo)
         XCTAssertEqual(violations[1].filePath, "\(tempDir)/Sources/World.swift")
         XCTAssertEqual(violations[1].locationInfo!.line, 1)
         XCTAssertEqual(violations[1].locationInfo!.charInLine, 9)
         XCTAssertEqual(violations[1].appliedAutoCorrection!.after, "50000_000")

         XCTAssertEqual(violations[2].checkInfo, checkInfo)
         XCTAssertEqual(violations[2].filePath, "\(tempDir)/Sources/World.swift")
         XCTAssertEqual(violations[2].locationInfo!.line, 2)
         XCTAssertEqual(violations[2].locationInfo!.charInLine, 9)
         XCTAssertEqual(violations[2].appliedAutoCorrection!.after, "100000000000_000")

         XCTAssertEqual(violations[3].checkInfo, checkInfo)
         XCTAssertEqual(violations[3].filePath, "\(tempDir)/Sources/World.swift")
         XCTAssertEqual(violations[3].locationInfo!.line, 1)
         XCTAssertEqual(violations[3].locationInfo!.charInLine, 9)
         XCTAssertEqual(violations[3].appliedAutoCorrection!.after, "50_000")

         XCTAssertEqual(violations[4].checkInfo, checkInfo)
         XCTAssertEqual(violations[4].filePath, "\(tempDir)/Sources/World.swift")
         XCTAssertEqual(violations[4].locationInfo!.line, 2)
         XCTAssertEqual(violations[4].locationInfo!.charInLine, 9)
         XCTAssertEqual(violations[4].appliedAutoCorrection!.after, "100000000_000")

         XCTAssertEqual(violations[5].checkInfo, checkInfo)
         XCTAssertEqual(violations[5].filePath, "\(tempDir)/Sources/World.swift")
         XCTAssertEqual(violations[5].locationInfo!.line, 2)
         XCTAssertEqual(violations[5].locationInfo!.charInLine, 9)
         XCTAssertEqual(violations[5].appliedAutoCorrection!.after, "100000_000")

         XCTAssertEqual(violations[6].checkInfo, checkInfo)
         XCTAssertEqual(violations[6].filePath, "\(tempDir)/Sources/World.swift")
         XCTAssertEqual(violations[6].locationInfo!.line, 2)
         XCTAssertEqual(violations[6].locationInfo!.charInLine, 9)
         XCTAssertEqual(violations[6].appliedAutoCorrection!.after, "100_000")
      }
   }
}
