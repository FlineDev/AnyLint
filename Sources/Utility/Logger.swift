import Foundation
import Rainbow

/// Helper to log output to console or elsewhere.
public final class Logger {
    /// The print level type.
    public enum PrintLevel: String {
        /// Print success information.
        case success

        /// Print any kind of information potentially interesting to users.
        case info

        /// Print information that might potentially be problematic.
        case warning

        /// Print information that probably is problematic.
        case error

        var color: Color {
            switch self {
            case .success:
                return Color.lightGreen

            case .info:
                return Color.lightBlue

            case .warning:
                return Color.yellow

            case .error:
                return Color.red
            }
        }
    }

    /// The output type.
    public enum OutputType {
        /// Output is targeted to a console to be read by developers.
        case console

        /// Output is targeted for unit tests. Collect into globally accessible TestHelper.
        case test
    }

    /// The exit status.
    public enum ExitStatus {
        /// Successfully finished task.
        case success

        /// Failed to finish task.
        case failure

        var statusCode: Int32 {
            switch self {
            case .success:
                return EXIT_SUCCESS

            case .failure:
                return EXIT_FAILURE
            }
        }
    }

    let outputType: OutputType

    init(outputType: OutputType) {
        self.outputType = outputType
    }

    /// Communicates a message to the chosen output target with proper formatting based on level & source.
    ///
    /// - Parameters:
    ///   - message: The message to be printed. Don't include `Error!`, `Warning!` or similar information at the beginning.
    ///   - level: The level of the print statement.
    public func message(_ message: String, level: PrintLevel) {
        switch outputType {
        case .console:
            consoleMessage(message, level: level)

        case .test:
            TestHelper.shared.consoleOutputs.append((message, level))
        }
    }

    /// Exits the current program with the given status.
    public func exit(status: ExitStatus) {
        switch outputType {
        case .console:
            Darwin.exit(status.statusCode)

        case .test:
            TestHelper.shared.exitStatus = status
        }
    }

    private func consoleMessage(_ message: String, level: PrintLevel) {
        switch level {
        case .success:
            print(formattedCurrentTime(), "✅ ", message.green)

        case .info:
            print(formattedCurrentTime(), "ℹ️ ", message.lightBlue)

        case .warning:
            print(formattedCurrentTime(), "⚠️ ", message.yellow)

        case .error:
            print(formattedCurrentTime(), "❌", message.red)
        }
    }

    private func formattedCurrentTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        let dateTime = dateFormatter.string(from: Date())
        return "\(dateTime):"
    }
}
