import Core
import Foundation

/// The possible templates for setting up configuration initially.
public enum Template: String, CaseIterable {
  /// The blank template with all existing checks and one 'Hello world' kind of example per check.
  case blank

  /// The template with some useful checks setup for open source projects.
  case openSource

  /// Returns the file contents for the chosen template.
  public var fileContents: Data {
    // NOTE: force unwrapping and force try safe together with `testFileContentsNotFailing` test & CI
    let templateFileUrl = Bundle.module.url(
      forResource: rawValue.firstUppercased,
      withExtension: "yml",
      subdirectory: "Templates"
    )!
    return try! Data(contentsOf: templateFileUrl)
  }
}

extension String {
  /// Returns a variation with the first character uppercased.
  fileprivate var firstUppercased: String { prefix(1).uppercased() + dropFirst() }
}
