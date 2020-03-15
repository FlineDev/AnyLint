@testable import AnyLint
@testable import Utility
import XCTest

final class FilesSearchTests: XCTestCase {
    private let tempDir: String = "AnyLintTempTests"

    override func setUp() {
        log = Logger(outputType: .test)
        TestHelper.shared.reset()
    }

    func testAllFilesWithinPath() {
        try? FileManager.default.createDirectory(atPath: "\(tempDir)/Sources", withIntermediateDirectories: true, attributes: nil)
        FileManager.default.createFile(atPath: "\(tempDir)/Hello.swift", contents: nil, attributes: nil)
        FileManager.default.createFile(atPath: "\(tempDir)/World.swift", contents: nil, attributes: nil)
        FileManager.default.createFile(atPath: "\(tempDir)/.hidden_file", contents: nil, attributes: nil)

        try? FileManager.default.createDirectory(atPath: "\(tempDir)/.hidden_dir", withIntermediateDirectories: true, attributes: nil)
        FileManager.default.createFile(atPath: "\(tempDir)/.hidden_dir/unhidden_file", contents: nil, attributes: nil)

        let includeFilterFilePaths = FilesSearch.allFiles(
            within: FileManager.default.currentDirectoryPath,
            includeFilters: [#"AnyLintTempTests/.*"#],
            excludeFilters: []
        )
        XCTAssertEqual(includeFilterFilePaths, ["\(tempDir)/Hello.swift", "\(tempDir)/World.swift"])

        let excludeFilterFilePaths = FilesSearch.allFiles(
            within: FileManager.default.currentDirectoryPath,
            includeFilters: [#"AnyLintTempTests/.*"#],
            excludeFilters: [#"World"#]
        )
        XCTAssertEqual(excludeFilterFilePaths, ["\(tempDir)/Hello.swift"])

        try? FileManager.default.removeItem(atPath: tempDir)
    }
}
