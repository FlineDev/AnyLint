import Foundation
import Core
import BetterCodable

/// The `CustomScripts` check configuration type.
public struct CustomScriptsConfiguration: CheckConfiguration, Codable {
  /// A unique identifier for the check to show on violations.
  public let id: String

  /// A hint that should be shown on violations of this check. Should explain what's wrong and guide on fixing the issue.
  public let hint: String

  /// The severity level of this check. One of `.info`, `.warning` or `.error`. Defaults to `.error`.
  @DefaultCodable<Severity.DefaultToError>
  public var severity: Severity

  /// The custom command line command to execute.
  /// If the output conforms to the ``LintResults`` structure formatted as JSON, then the results will be merged.
  /// Otherwise AnyLint will violate for any non-zero exit code with the last printed line.
  public let command: String
}
