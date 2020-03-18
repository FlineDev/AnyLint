@testable import AnyLint
import Rainbow
@testable import Utility
import XCTest

final class ViolationTests: XCTestCase {
    override func setUp() {
        log = Logger(outputType: .test)
        TestHelper.shared.reset()
        Statistics.shared.reset()
    }

    func testLogMessage() {
        let checkInfo = CheckInfo(id: "demo_check", hint: "Make sure to always check the demo.", severity: .warning)
        Violation(checkInfo: checkInfo).logMessage()

        XCTAssertEqual(TestHelper.shared.consoleOutputs.count, 1)
        XCTAssertEqual(TestHelper.shared.consoleOutputs[0].level, .warning)
        XCTAssertEqual(TestHelper.shared.consoleOutputs[0].message, "\("[demo_check]".bold) Make sure to always check the demo.")

        Violation(checkInfo: checkInfo, filePath: "Temp/Souces/Hello.swift").logMessage()

        XCTAssertEqual(TestHelper.shared.consoleOutputs.count, 2)
        XCTAssertEqual(TestHelper.shared.consoleOutputs[1].level, .warning)
        XCTAssertEqual(TestHelper.shared.consoleOutputs[1].message, "Temp/Souces/Hello.swift: \("[demo_check]".bold) Make sure to always check the demo.")

        Violation(checkInfo: checkInfo, filePath: "Temp/Souces/World.swift", locationInfo: String.LocationInfo(line: 5, charInLine: 15)).logMessage()

        XCTAssertEqual(TestHelper.shared.consoleOutputs.count, 3)
        XCTAssertEqual(TestHelper.shared.consoleOutputs[2].level, .warning)
        XCTAssertEqual(TestHelper.shared.consoleOutputs[2].message, "Temp/Souces/World.swift:5:15: \("[demo_check]".bold) Make sure to always check the demo.")
    }
}
