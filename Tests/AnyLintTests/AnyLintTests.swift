import XCTest
@testable import AnyLint

final class AnyLintTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(AnyLint().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
