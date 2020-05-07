@testable import AnyLint
@testable import Utility
import XCTest

// swiftlint:disable force_try

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
            let includeFilterFilePaths = FilesSearch.shared.allFiles(
                within: FileManager.default.currentDirectoryPath,
                includeFilters: [try Regex("\(tempDir)/.*")],
                excludeFilters: []
            )
            XCTAssertEqual(includeFilterFilePaths, ["\(tempDir)/Sources/Hello.swift", "\(tempDir)/Sources/World.swift"])

            let excludeFilterFilePaths = FilesSearch.shared.allFiles(
                within: FileManager.default.currentDirectoryPath,
                includeFilters: [try Regex("\(tempDir)/.*")],
                excludeFilters: ["World"]
            )
            XCTAssertEqual(excludeFilterFilePaths, ["\(tempDir)/Sources/Hello.swift"])
        }
    }

    func testPerformanceOfSameSearchOptions() {
        let swiftSourcesFilePaths = (0 ... 800).map { (subpath: "Sources/Foo\($0).swift", contents: "Lorem ipsum\ndolor sit amet\n") }
        let testsFilePaths = (0 ... 400).map { (subpath: "Tests/Foo\($0).swift", contents: "Lorem ipsum\ndolor sit amet\n") }
        let storyboardSourcesFilePaths = (0 ... 300).map { (subpath: "Sources/Foo\($0).storyboard", contents: "Lorem ipsum\ndolor sit amet\n") }

        withTemporaryFiles(swiftSourcesFilePaths + testsFilePaths + storyboardSourcesFilePaths) { _ in
            let fileSearchCode: () -> [String] = {
                FilesSearch.shared.allFiles(
                    within: FileManager.default.currentDirectoryPath,
                    includeFilters: [try! Regex(#"\#(self.tempDir)/Sources/Foo.*"#)],
                    excludeFilters: [try! Regex(#"\#(self.tempDir)/.*\.storyboard"#)]
                )
            }

            // first run
            XCTAssertEqual(Set(fileSearchCode()), Set(swiftSourcesFilePaths.map { "\(tempDir)/\($0.subpath)" }))

            measure {
                // subsequent runs (should be much faster)
                XCTAssertEqual(Set(fileSearchCode()), Set(swiftSourcesFilePaths.map { "\(tempDir)/\($0.subpath)" }))
                XCTAssertEqual(Set(fileSearchCode()), Set(swiftSourcesFilePaths.map { "\(tempDir)/\($0.subpath)" }))
            }
        }
    }
}
