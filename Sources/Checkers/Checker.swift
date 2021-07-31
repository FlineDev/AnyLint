import Foundation
import Core

/// Defines how a checker algorithm behaves to produce violations results.
public protocol Checker {
  /// Executes the checks and returns violations (if any).
  func performCheck() throws -> [Violation]
}
