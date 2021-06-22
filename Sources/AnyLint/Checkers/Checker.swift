import Foundation

protocol Checker {
  func performCheck() throws -> [Violation]
}
