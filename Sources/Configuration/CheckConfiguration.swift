import Foundation
import Core

/// Defines fields each check configuration needs to have.
public protocol CheckConfiguration {
  var id: String { get }
  var hint: String { get }
  var severity: Severity { get }
}
