import Foundation

protocol Checker {
    func performCheck() -> [Violation]
}
