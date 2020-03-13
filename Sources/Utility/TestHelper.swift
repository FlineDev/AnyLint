import Foundation

/// A helper class for Unit Testing only. Only put data in here when `isStartedByUnitTests` is set to true.
/// Never read other data in framework than that property.
public final class TestHelper {
    /// The console output data.
    public typealias ConsoleOutput = (message: String, level: Logger.PrintLevel, file: String?, line: Int?)

    /// The shared `TestHelper` object.
    public static let shared = TestHelper()

    /// Set to `true` within unit tests (in `setup()`). Defaults to `false`.
    public var isStartedByUnitTests: Bool = false

    /// Use only in Unit Tests.
    public var consoleOutputs: [ConsoleOutput] = []

    /// Deletes all data collected until now.
    public func reset() {
        consoleOutputs = []
    }
}
