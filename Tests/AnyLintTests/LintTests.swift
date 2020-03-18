@testable import AnyLint
@testable import Utility
import XCTest

final class LintTests: XCTestCase {
    override func setUp() {
        log = Logger(outputType: .test)
        TestHelper.shared.reset()
    }

    func testValidateRegexMatchesForEach() {
        XCTAssertNil(TestHelper.shared.exitStatus)

        let regex: Regex = #"foo[0-9]?bar"#
        let checkInfo = CheckInfo(id: "foo_bar", hint: "do bar", severity: .warning)

        Lint.validate(
            regex: regex,
            matchesForEach: ["foo1bar", "foobar", "myfoo4barbeque"],
            checkInfo: checkInfo
        )
        XCTAssertNil(TestHelper.shared.exitStatus)

        Lint.validate(
            regex: regex,
            matchesForEach: ["foo1bar", "FooBar", "myfoo4barbeque"],
            checkInfo: checkInfo
        )
        XCTAssertEqual(TestHelper.shared.exitStatus, .failure)
    }

    func testValidateRegexDoesNotMatchAny() {
        XCTAssertNil(TestHelper.shared.exitStatus)

        let regex: Regex = #"foo[0-9]?bar"#
        let checkInfo = CheckInfo(id: "foo_bar", hint: "do bar", severity: .warning)

        Lint.validate(
            regex: regex,
            doesNotMatchAny: ["fooLbar", "FooBar", "myfoo40barbeque"],
            checkInfo: checkInfo
        )
        XCTAssertNil(TestHelper.shared.exitStatus)

        Lint.validate(
            regex: regex,
            doesNotMatchAny: ["fooLbar", "foobar", "myfoo40barbeque"],
            checkInfo: checkInfo
        )
        XCTAssertEqual(TestHelper.shared.exitStatus, .failure)
    }

    func testValidateAutocorrectsAllExamples() {
        XCTAssertNil(TestHelper.shared.exitStatus)

        // TODO: [cg_2020-03-18] not yet implemented
    }
}
