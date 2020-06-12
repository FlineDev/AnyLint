import Foundation

protocol Checker {
    func performCheck() throws -> [CheckInfo: [Violation]]
}
