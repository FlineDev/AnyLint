// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
@testable import AnyLintTests
@testable import Utility
import XCTest

// swiftlint:disable line_length file_length

extension ArrayExtTests {
    static var allTests: [(String, (ArrayExtTests) -> () throws -> Void)] = [
        ("testContainsLineAtIndexesMatchingRegex", testContainsLineAtIndexesMatchingRegex)
    ]
}

extension AutoCorrectionTests {
    static var allTests: [(String, (AutoCorrectionTests) -> () throws -> Void)] = [
        ("testInitWithDictionaryLiteral", testInitWithDictionaryLiteral),
        ("testAppliedMessageLines", testAppliedMessageLines)
    ]
}

extension CheckInfoTests {
    static var allTests: [(String, (CheckInfoTests) -> () throws -> Void)] = [
        ("testInitWithStringLiteral", testInitWithStringLiteral)
    ]
}

extension FileContentsCheckerTests {
    static var allTests: [(String, (FileContentsCheckerTests) -> () throws -> Void)] = [
        ("testPerformCheck", testPerformCheck),
        ("testSkipInFile", testSkipInFile),
        ("testSkipHere", testSkipHere),
        ("testSkipIfEqualsToAutocorrectReplacement", testSkipIfEqualsToAutocorrectReplacement),
        ("testRepeatIfAutoCorrected", testRepeatIfAutoCorrected)
    ]
}

extension FilePathsCheckerTests {
    static var allTests: [(String, (FilePathsCheckerTests) -> () throws -> Void)] = [
        ("testPerformCheck", testPerformCheck)
    ]
}

extension FilesSearchTests {
    static var allTests: [(String, (FilesSearchTests) -> () throws -> Void)] = [
        ("testAllFilesWithinPath", testAllFilesWithinPath),
        ("testPerformanceOfSameSearchOptions", testPerformanceOfSameSearchOptions)
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

extension RegexExtTests {
    static var allTests: [(String, (RegexExtTests) -> () throws -> Void)] = [
        ("testInitWithStringLiteral", testInitWithStringLiteral),
        ("testInitWithDictionaryLiteral", testInitWithDictionaryLiteral)
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
    testCase(ArrayExtTests.allTests),
    testCase(AutoCorrectionTests.allTests),
    testCase(CheckInfoTests.allTests),
    testCase(FileContentsCheckerTests.allTests),
    testCase(FilePathsCheckerTests.allTests),
    testCase(FilesSearchTests.allTests),
    testCase(LintTests.allTests),
    testCase(RegexExtTests.allTests),
    testCase(StatisticsTests.allTests),
    testCase(ViolationTests.allTests)
])
