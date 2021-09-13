@testable import Checkers
import XCTest
import Core
import TestSupport

final class FileContentsCheckerTests: XCTestCase {
  func testPerformCheck() {
    let temporaryFiles: [TemporaryFile] = [
      (subpath: "Sources/Hello.swift", contents: "let x = 5\nvar y = 10"),
      (subpath: "Sources/World.swift", contents: "let x=5\nvar y=10"),
    ]

    withTemporaryFiles(temporaryFiles) { filePathsToCheck in
      let violations = try FileContentsChecker(
        id: "Whitespacing",
        hint: "Always add a single whitespace around '='.",
        severity: .warning,
        regex: Regex(#"(let|var) \w+=\w+"#),
        filePathsToCheck: filePathsToCheck,
        autoCorrectReplacement: nil,
        repeatIfAutoCorrected: false
      )
      .performCheck()

      XCTAssertEqual(violations.count, 2)

      XCTAssertEqual(violations[0].matchedString, "let x=5")
      XCTAssertEqual(violations[0].location?.filePath, "\(tempDir)/Sources/World.swift")
      XCTAssertEqual(violations[0].location?.row, 1)
      XCTAssertEqual(violations[0].location!.column, 1)

      XCTAssertEqual(violations[1].matchedString, "var y=10")
      XCTAssertEqual(violations[1].location?.filePath, "\(tempDir)/Sources/World.swift")
      XCTAssertEqual(violations[1].location?.row, 2)
      XCTAssertEqual(violations[1].location?.column, 1)
    }
  }

  func testSkipInFile() {
    let temporaryFiles: [TemporaryFile] = [
      (
        subpath: "Sources/Hello.swift",
        contents: "// AnyLint.skipInFile: OtherRule, Whitespacing\n\n\nlet x=5\nvar y=10"
      ),
      (subpath: "Sources/World.swift", contents: "// AnyLint.skipInFile: All\n\n\nlet x=5\nvar y=10"),
      (subpath: "Sources/Foo.swift", contents: "// AnyLint.skipInFile: OtherRule\n\n\nlet x=5\nvar y=10"),
    ]

    withTemporaryFiles(temporaryFiles) { filePathsToCheck in
      let violations = try FileContentsChecker(
        id: "Whitespacing",
        hint: "Always add a single whitespace around '='.",
        severity: .warning,
        regex: Regex(#"(let|var) \w+=\w+"#),
        filePathsToCheck: filePathsToCheck,
        autoCorrectReplacement: nil,
        repeatIfAutoCorrected: false
      )
      .performCheck()

      XCTAssertEqual(violations.count, 2)

      XCTAssertEqual(violations[0].matchedString, "let x=5")
      XCTAssertEqual(violations[0].location?.filePath, "\(tempDir)/Sources/Foo.swift")
      XCTAssertEqual(violations[0].location?.row, 4)
      XCTAssertEqual(violations[0].location?.column, 1)

      XCTAssertEqual(violations[1].matchedString, "var y=10")
      XCTAssertEqual(violations[1].location?.filePath, "\(tempDir)/Sources/Foo.swift")
      XCTAssertEqual(violations[1].location?.row, 5)
      XCTAssertEqual(violations[1].location?.column, 1)
    }
  }

  func testSkipHere() {
    let temporaryFiles: [TemporaryFile] = [
      (subpath: "Sources/Hello.swift", contents: "// AnyLint.skipHere: OtherRule, Whitespacing\n\n\nlet x=5\nvar y=10"),
      (subpath: "Sources/World.swift", contents: "\n\n// AnyLint.skipHere: OtherRule, Whitespacing\nlet x=5\nvar y=10"),
      (
        subpath: "Sources/Foo.swift", contents: "\n\n\nlet x=5\nvar y=10 // AnyLint.skipHere: OtherRule, Whitespacing\n"
      ),
      (subpath: "Sources/Bar.swift", contents: "\n\n\nlet x=5\nvar y=10\n// AnyLint.skipHere: OtherRule, Whitespacing"),
    ]

    withTemporaryFiles(temporaryFiles) { filePathsToCheck in
      let violations = try FileContentsChecker(
        id: "Whitespacing",
        hint: "Always add a single whitespace around '='.",
        severity: .warning,
        regex: Regex(#"(let|var) \w+=\w+"#),
        filePathsToCheck: filePathsToCheck,
        autoCorrectReplacement: nil,
        repeatIfAutoCorrected: false
      )
      .performCheck()

      XCTAssertEqual(violations.count, 6)

      XCTAssertEqual(violations[0].matchedString, "let x=5")
      XCTAssertEqual(violations[0].location?.filePath, "\(tempDir)/Sources/Hello.swift")
      XCTAssertEqual(violations[0].location?.row, 4)
      XCTAssertEqual(violations[0].location?.column, 1)

      XCTAssertEqual(violations[1].matchedString, "var y=10")
      XCTAssertEqual(violations[1].location?.filePath, "\(tempDir)/Sources/Hello.swift")
      XCTAssertEqual(violations[1].location?.row, 5)
      XCTAssertEqual(violations[1].location?.column, 1)

      XCTAssertEqual(violations[2].matchedString, "var y=10")
      XCTAssertEqual(violations[2].location?.filePath, "\(tempDir)/Sources/World.swift")
      XCTAssertEqual(violations[2].location?.row, 5)
      XCTAssertEqual(violations[2].location?.column, 1)

      XCTAssertEqual(violations[3].matchedString, "let x=5")
      XCTAssertEqual(violations[3].location?.filePath, "\(tempDir)/Sources/Foo.swift")
      XCTAssertEqual(violations[3].location?.row, 4)
      XCTAssertEqual(violations[3].location?.column, 1)

      XCTAssertEqual(violations[4].matchedString, "let x=5")
      XCTAssertEqual(violations[4].location?.filePath, "\(tempDir)/Sources/Bar.swift")
      XCTAssertEqual(violations[4].location?.row, 4)
      XCTAssertEqual(violations[4].location?.column, 1)

      XCTAssertEqual(violations[5].matchedString, "var y=10")
      XCTAssertEqual(violations[5].location?.filePath, "\(tempDir)/Sources/Bar.swift")
      XCTAssertEqual(violations[5].location?.row, 5)
      XCTAssertEqual(violations[5].location?.column, 1)
    }
  }

  func testSkipIfEqualsToAutocorrectReplacement() {
    let temporaryFiles: [TemporaryFile] = [
      (subpath: "Sources/Hello.swift", contents: "let x = 5\nvar y = 10"),
      (subpath: "Sources/World.swift", contents: "let x =5\nvar y= 10"),
    ]

    withTemporaryFiles(temporaryFiles) { filePathsToCheck in
      let violations = try FileContentsChecker(
        id: "Whitespacing",
        hint: "Always add a single whitespace around '='.",
        severity: .warning,
        regex: Regex(#"(let|var) (\w+)\s*=\s*(\w+)"#),
        filePathsToCheck: filePathsToCheck,
        autoCorrectReplacement: "$1 $2 = $3",
        repeatIfAutoCorrected: false
      )
      .performCheck()

      XCTAssertEqual(violations.count, 2)

      XCTAssertEqual(violations[0].matchedString, "let x =5")
      XCTAssertEqual(violations[0].location?.filePath, "\(tempDir)/Sources/World.swift")
      XCTAssertEqual(violations[0].location?.row, 1)
      XCTAssertEqual(violations[0].location?.column, 1)

      XCTAssertEqual(violations[1].matchedString, "var y= 10")
      XCTAssertEqual(violations[1].location?.filePath, "\(tempDir)/Sources/World.swift")
      XCTAssertEqual(violations[1].location?.row, 2)
      XCTAssertEqual(violations[1].location?.column, 1)
    }
  }

  func testRepeatIfAutoCorrected() {
    let temporaryFiles: [TemporaryFile] = [
      (subpath: "Sources/Hello.swift", contents: "let x = 500\nvar y = 10000"),
      (subpath: "Sources/World.swift", contents: "let x = 50000000\nvar y = 100000000000000"),
    ]

    withTemporaryFiles(temporaryFiles) { filePathsToCheck in
      let violations = try FileContentsChecker(
        id: "LongNumbers",
        hint: "Format long numbers with `_` after each triple of digits from the right.",
        severity: .warning,
        regex: Regex(#"(?<!\d)(\d+)(\d{3})(?!\d)"#),
        filePathsToCheck: filePathsToCheck,
        autoCorrectReplacement: "$1_$2",
        repeatIfAutoCorrected: true
      )
      .performCheck()

      XCTAssertEqual(violations.count, 7)

      XCTAssertEqual(violations[0].matchedString, "10000")
      XCTAssertEqual(violations[0].location?.filePath, "\(tempDir)/Sources/Hello.swift")
      XCTAssertEqual(violations[0].location?.row, 2)
      XCTAssertEqual(violations[0].location?.column, 9)
      XCTAssertEqual(violations[0].appliedAutoCorrection!.after, "10_000")

      XCTAssertEqual(violations[1].matchedString, "50000000")
      XCTAssertEqual(violations[1].location?.filePath, "\(tempDir)/Sources/World.swift")
      XCTAssertEqual(violations[1].location?.row, 1)
      XCTAssertEqual(violations[1].location?.column, 9)
      XCTAssertEqual(violations[1].appliedAutoCorrection!.after, "50000_000")

      XCTAssertEqual(violations[2].matchedString, "100000000000000")
      XCTAssertEqual(violations[2].location?.filePath, "\(tempDir)/Sources/World.swift")
      XCTAssertEqual(violations[2].location?.row, 2)
      XCTAssertEqual(violations[2].location?.column, 9)
      XCTAssertEqual(violations[2].appliedAutoCorrection!.after, "100000000000_000")

      XCTAssertEqual(violations[3].matchedString, "50000")
      XCTAssertEqual(violations[3].location?.filePath, "\(tempDir)/Sources/World.swift")
      XCTAssertEqual(violations[3].location?.row, 1)
      XCTAssertEqual(violations[3].location?.column, 9)
      XCTAssertEqual(violations[3].appliedAutoCorrection!.after, "50_000")

      XCTAssertEqual(violations[4].matchedString, "100000000000")
      XCTAssertEqual(violations[4].location?.filePath, "\(tempDir)/Sources/World.swift")
      XCTAssertEqual(violations[4].location?.row, 2)
      XCTAssertEqual(violations[4].location?.column, 9)
      XCTAssertEqual(violations[4].appliedAutoCorrection!.after, "100000000_000")

      XCTAssertEqual(violations[5].matchedString, "100000000")
      XCTAssertEqual(violations[5].location?.filePath, "\(tempDir)/Sources/World.swift")
      XCTAssertEqual(violations[5].location?.row, 2)
      XCTAssertEqual(violations[5].location?.column, 9)
      XCTAssertEqual(violations[5].appliedAutoCorrection!.after, "100000_000")

      XCTAssertEqual(violations[6].matchedString, "100000")
      XCTAssertEqual(violations[6].location?.filePath, "\(tempDir)/Sources/World.swift")
      XCTAssertEqual(violations[6].location?.row, 2)
      XCTAssertEqual(violations[6].location?.column, 9)
      XCTAssertEqual(violations[6].appliedAutoCorrection!.after, "100_000")
    }
  }
}
