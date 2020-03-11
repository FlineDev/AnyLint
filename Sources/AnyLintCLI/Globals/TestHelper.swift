import Foundation

/// A helper class for Unit Testing only. Only put data in here when `isStartedByUnitTests` is set to true.
/// Never read other data in framework than that property.
final class TestHelper {
    typealias ConsoleOutput = (message: String, level: Logger.PrintLevel, file: String?, line: Int?)

    static let shared = TestHelper()

    /// Set to `true` within unit tests (in `setup()`). Defaults to `false`.
    var isStartedByUnitTests: Bool = false

    /// Use only in Unit Tests.
    var consoleOutputs: [ConsoleOutput] = []

    /// Deletes all data collected until now.
    func reset() {
        consoleOutputs = []
    }
}
