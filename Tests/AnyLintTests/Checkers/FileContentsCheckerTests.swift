@testable import AnyLint
@testable import Utility
import XCTest

final class FileContentsCheckerTests: XCTestCase {
    override func setUp() {
        log = Logger(outputType: .test)
        TestHelper.shared.reset()
    }

    func testPerformCheck() {
        // TODO: [cg_2020-03-15] not yet implemented
    }
}
