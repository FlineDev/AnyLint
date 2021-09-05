@testable import Checkers
import XCTest
import Core
import TestSupport

final class FilePathsCheckerTests: XCTestCase {
  func testPerformCheck() {
    withTemporaryFiles(
      [
        (subpath: "Sources/Hello.swift", contents: ""),
        (subpath: "Sources/World.swift", contents: ""),
      ]
    ) { filePathsToCheck in
      let violations = try sayHelloChecker(filePathsToCheck: filePathsToCheck).performCheck()
      XCTAssertEqual(violations.count, 0)
    }

    withTemporaryFiles([(subpath: "Sources/World.swift", contents: "")]) { filePathsToCheck in
      let violations = try sayHelloChecker(filePathsToCheck: filePathsToCheck).performCheck()

      XCTAssertEqual(violations.count, 1)
      XCTAssertNil(violations[0].fileLocation)
    }

    withTemporaryFiles(
      [
        (subpath: "Sources/Hello.swift", contents: ""),
        (subpath: "Sources/World.swift", contents: ""),
      ]
    ) { filePathsToCheck in
      let violations = try noWorldChecker(filePathsToCheck: filePathsToCheck).performCheck()

      XCTAssertEqual(violations.count, 1)
      XCTAssertEqual(violations[0].fileLocation?.filePath, "\(tempDir)/Sources/World.swift")
      XCTAssertNil(violations[0].fileLocation?.row)
      XCTAssertNil(violations[0].fileLocation?.column)
    }
  }

  private func sayHelloChecker(filePathsToCheck: [String]) -> FilePathsChecker {
    FilePathsChecker(
      id: "say_hello",
      hint: "Should always say hello.",
      severity: .info,
      regex: try! Regex(#".*Hello\.swift"#),
      filePathsToCheck: filePathsToCheck,
      autoCorrectReplacement: nil,
      violateIfNoMatchesFound: true
    )
  }

  private func noWorldChecker(filePathsToCheck: [String]) -> FilePathsChecker {
    FilePathsChecker(
      id: "no_world",
      hint: "Do not include the global world, be more specific instead.",
      severity: .error,
      regex: try! Regex(#".*World\.swift"#),
      filePathsToCheck: filePathsToCheck,
      autoCorrectReplacement: nil,
      violateIfNoMatchesFound: false
    )
  }
}
