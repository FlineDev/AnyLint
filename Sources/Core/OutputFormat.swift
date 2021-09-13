import Foundation

/// The output format of violations and other statistics.
public enum OutputFormat: String, CaseIterable {
  /// Output to the command line. Includes both violations & statistics summary at end.
  case commandLine

  /// Output targeted to Xcode IDE. Includes only violations in the Xcode warning/error format. No statistics.
  case xcode

  /// Output targeted to further usage from other tools or configurations. Output format same as script output, both violations & statistics.
  case json
}
