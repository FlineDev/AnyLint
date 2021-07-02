import Foundation
import Core

/// The checker for the `CustomScripts` configuration. Runs custom commands and checks their output & status for determining violations.
public struct CustomScriptsChecker {
  /// The identifier of the check defined here. Can be used when defining exceptions within files for specific lint checks.
  public let id: String

  /// The hint to be shown as guidance on what the issue is and how to fix it. Can reference any capture groups in the first regex parameter (e.g. `contentRegex`).
  public let hint: String

  /// The severity level for the report in case the check fails.
  public let severity: Severity

  /// The script to execute. Expected output can be AnyLint standardized JSON or, if not, will use exit code to determine failed or not.
  public let script: String
}

extension CustomScriptsChecker: Checker {
  public func performCheck() throws -> [Violation] {
    fatalError()  // TODO: [cg_2021-07-02] not yet implemented
  }
}
