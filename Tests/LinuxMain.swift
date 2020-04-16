// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

@testable import AnyLintTests
@testable import Utility
import XCTest

// swiftlint:disable line_length file_length

extension AnyLintCLITests {
    static var allTests: [(String, (AnyLintCLITests) -> () throws -> Void)] = [
        ("testExample", testExample)
    ]
}

extension AutoCorrectionTests {
    static var allTests: [(String, (AutoCorrectionTests) -> () throws -> Void)] = [
        ("testInitWithDictionaryLiteral", testInitWithDictionaryLiteral)
    ]
}

extension CheckInfoTests {
    static var allTests: [(String, (CheckInfoTests) -> () throws -> Void)] = [
        ("testInitWithStringLiteral", testInitWithStringLiteral)
    ]
}

extension FileContentsCheckerTests {
    static var allTests: [(String, (FileContentsCheckerTests) -> () throws -> Void)] = [
        ("testPerformCheck", testPerformCheck)
    ]
}

extension FilePathsCheckerTests {
    static var allTests: [(String, (FilePathsCheckerTests) -> () throws -> Void)] = [
        ("testPerformCheck", testPerformCheck)
    ]
}

extension FilesSearchTests {
    static var allTests: [(String, (FilesSearchTests) -> () throws -> Void)] = [
        ("testAllFilesWithinPath", testAllFilesWithinPath)
    ]
}

extension LintTests {
    static var allTests: [(String, (LintTests) -> () throws -> Void)] = [
        ("testValidateRegexMatchesForEach", testValidateRegexMatchesForEach),
        ("testValidateRegexDoesNotMatchAny", testValidateRegexDoesNotMatchAny),
        ("testValidateAutocorrectsAllExamplesWithAnonymousGroups", testValidateAutocorrectsAllExamplesWithAnonymousGroups),
        ("testValidateAutocorrectsAllExamplesWithNamedGroups", testValidateAutocorrectsAllExamplesWithNamedGroups)
    ]
}

extension LoggerTests {
    static var allTests: [(String, (LoggerTests) -> () throws -> Void)] = [
        ("testMessage", testMessage)
    ]
}

extension RegexExtTests {
    static var allTests: [(String, (RegexExtTests) -> () throws -> Void)] = [
        ("testInitWithStringLiteral", testInitWithStringLiteral),
        ("testInitWithDictionaryLiteral", testInitWithDictionaryLiteral),
        ("testStringLiteralInit", testStringLiteralInit)
    ]
}

extension StatisticsTests {
    static var allTests: [(String, (StatisticsTests) -> () throws -> Void)] = [
        ("testFoundViolationsInCheck", testFoundViolationsInCheck),
        ("testLogSummary", testLogSummary)
    ]
}

extension ViolationTests {
    static var allTests: [(String, (ViolationTests) -> () throws -> Void)] = [
        ("testLocationMessage", testLocationMessage)
    ]
}

XCTMain([
    testCase(AnyLintCLITests.allTests),
    testCase(AutoCorrectionTests.allTests),
    testCase(CheckInfoTests.allTests),
    testCase(FileContentsCheckerTests.allTests),
    testCase(FilePathsCheckerTests.allTests),
    testCase(FilesSearchTests.allTests),
    testCase(LintTests.allTests),
    testCase(LoggerTests.allTests),
    testCase(RegexExtTests.allTests),
    testCase(StatisticsTests.allTests),
    testCase(ViolationTests.allTests)
])
