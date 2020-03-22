@testable import AnyLint
@testable import Utility
import XCTest

final class FilesSearchTests: XCTestCase {
    override func setUp() {
        log = Logger(outputType: .test)
        TestHelper.shared.reset()
    }

    func testAllFilesWithinPath() {
        withTemporaryFiles(
            [
                (subpath: "Sources/Hello.swift", contents: ""),
                (subpath: "Sources/World.swift", contents: ""),
                (subpath: "Sources/.hidden_file", contents: ""),
                (subpath: "Sources/.hidden_dir/unhidden_file", contents: ""),
            ]
        ) { _ in
            let includeFilterFilePaths = FilesSearch.allFiles(
                within: FileManager.default.currentDirectoryPath,
                includeFilters: [try Regex("\(tempDir)/.*")],
                excludeFilters: []
            )
            XCTAssertEqual(includeFilterFilePaths, ["\(tempDir)/Sources/Hello.swift", "\(tempDir)/Sources/World.swift"])

            let excludeFilterFilePaths = FilesSearch.allFiles(
                within: FileManager.default.currentDirectoryPath,
                includeFilters: [try Regex("\(tempDir)/.*")],
                excludeFilters: ["World"]
            )
            XCTAssertEqual(excludeFilterFilePaths, ["\(tempDir)/Sources/Hello.swift"])
        }
    }
}
