import Foundation
import Core

/// Defines how a checker algorithm behaves to produce violations results.
public protocol Checker {
  func performCheck() throws -> [Violation]
}
