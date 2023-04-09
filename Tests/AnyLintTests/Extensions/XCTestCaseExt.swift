@testable import AnyLint
import Foundation
import XCTest

extension XCTestCase {
   typealias TemporaryFile = (subpath: String, contents: String)

   var tempDir: String { "AnyLintTempTests" }

   func withTemporaryFiles(_ temporaryFiles: [TemporaryFile], testCode: ([String]) throws -> Void) {
      var filePathsToCheck: [String] = []

      for tempFile in temporaryFiles {
         let tempFileUrl = FileManager.default.currentDirectoryUrl.appendingPathComponent(tempDir).appendingPathComponent(tempFile.subpath)
         let tempFileParentDirUrl = tempFileUrl.deletingLastPathComponent()
         try? FileManager.default.createDirectory(atPath: tempFileParentDirUrl.path, withIntermediateDirectories: true, attributes: nil)
         FileManager.default.createFile(atPath: tempFileUrl.path, contents: tempFile.contents.data(using: .utf8), attributes: nil)
         filePathsToCheck.append(tempFileUrl.relativePathFromCurrent)
      }

      try? testCode(filePathsToCheck)

      try? FileManager.default.removeItem(atPath: tempDir)
   }
}
