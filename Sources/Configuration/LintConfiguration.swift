import Foundation
import Core
import BetterCodable

/// The configuration file type.
public struct LintConfiguration: Codable {
  enum CodingKeys: String, CodingKey {
    case fileContents = "FileContents"
    case filePaths = "FilePaths"
    case customScripts = "CustomScripts"
  }

  /// The list of `FileContents` checks.
  @DefaultEmptyArray
  public var fileContents: [FileContentsConfiguration]

  /// The list of `FilePaths` checks.
  @DefaultEmptyArray
  public var filePaths: [FilePathsConfiguration]

  /// The list of `CustomScripts` checks.
  @DefaultEmptyArray
  public var customScripts: [CustomScriptsConfiguration]
}
