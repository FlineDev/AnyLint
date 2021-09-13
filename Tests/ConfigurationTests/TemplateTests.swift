import Foundation
import XCTest
import Yams
@testable import Configuration

final class TemplateTests: XCTestCase {
  func testFileContentsNotFailing() {
    for template in Template.allCases {
      XCTAssertFalse(template.fileContents.isEmpty)
    }
  }

  func testBlankIsValidYAMLConfig() throws {
    let configFileData = Template.blank.fileContents
    let lintConfig: LintConfiguration = try YAMLDecoder().decode(from: configFileData)

    XCTAssert(lintConfig.filePaths.isEmpty)
    XCTAssert(lintConfig.fileContents.isEmpty)
    XCTAssert(lintConfig.customScripts.isEmpty)
  }

  func testOpenSourceIsValidYAMLConfig() throws {
    let configFileData = Template.openSource.fileContents
    let lintConfig: LintConfiguration = try YAMLDecoder().decode(from: configFileData)

    XCTAssertFalse(lintConfig.filePaths.isEmpty)
    XCTAssertFalse(lintConfig.fileContents.isEmpty)
    XCTAssertFalse(lintConfig.customScripts.isEmpty)
  }
}
