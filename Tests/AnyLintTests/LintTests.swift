@testable import AnyLint
@testable import Utility
import XCTest

final class LintTests: XCTestCase {
    override func setUp() {
        log = Logger(outputType: .test)
        TestHelper.shared.reset()
    }

    func testCheckFileContents() {
        // TODO: [cg_2020-03-15] not yet implemented
    }

    func testCheckFilePaths() {
        // TODO: [cg_2020-03-15] not yet implemented
    }

    func testCheckLastCommitMessage() {
        // TODO: [cg_2020-03-15] not yet implemented
    }

    func testCustomCheck() {
        // TODO: [cg_2020-03-15] not yet implemented
    }

    func testLogSummaryAndExit() {
        // TODO: [cg_2020-03-15] not yet implemented
    }

    func testValidateRegexMatchesForEach() {
        // TODO: [cg_2020-03-15] not yet implemented
    }

    func testValidateRegexDoesNotMatchAny() {
        // TODO: [cg_2020-03-15] not yet implemented
    }
}
