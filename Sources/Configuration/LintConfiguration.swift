import Foundation
import Core

/// The configuration file type.
public struct LintConfiguration: Codable {
  enum CodingKeys: String, CodingKey {
    case fileContents = "CheckFileContents"
    case filePaths = "CheckFilePaths"
    case customScripts = "CustomScripts"
  }

  /// The list of `FileContents` checks.
  public let fileContents: [FileContentsConfiguration]

  /// The list of `FilePaths` checks.
  public let filePaths: [FilePathsConfiguration]

  /// The list of `CustomScripts` checks.
  public let customScripts: [CustomScriptsConfiguration]
}
