import Foundation

/// The template for setting up configuration initially.
public enum Template: String, CaseIterable {
  /// The blank template with all existing checks and one 'Hello world' kind of example per check.
  case blank

  /// The template with some useful checks setup for open source projects.
  case openSource
}
