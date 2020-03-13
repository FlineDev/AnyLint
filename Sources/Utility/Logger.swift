import Foundation
import Rainbow

// swiftlint:disable logger

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

        /// Output is targeted to Xcode. Native support for Xcode Warnings & Errors.
        case xcode

        /// Output is targeted for unit tests. Collect into globally accessible TestHelper.
        case test
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
    ///   - file: The file this print statement refers to. Used for showing errors/warnings within Xcode if run as script phase.
    ///   - line: The line within the file this print statement refers to. Used for showing errors/warnings within Xcode if run as script phase.
    public func message(_ message: String, level: PrintLevel, file: String? = nil, line: Int? = nil) {
        switch outputType {
        case .console:
            consoleMessage(message, level: level, file: file, line: line)

        case .xcode:
            xcodeMessage(message, level: level, file: file, line: line)

        case .test:
            TestHelper.shared.consoleOutputs.append((message, level, file, line))
        }
    }

    private func consoleMessage(_ message: String, level: PrintLevel, file: String? = nil, line: Int? = nil, charInLine: Int? = nil) {
        let location = locationInfo(file: file, line: line, charInLine: charInLine)?.replacingOccurrences(of: fileManager.currentDirectoryPath, with: ".")
        let message = location != nil ? [location!, message].joined(separator: " ") : message

        switch level {
        case .success:
            print(formattedCurrentTime(), "✅ ", message.lightGreen)

        case .info:
            print(formattedCurrentTime(), "ℹ️ ", message.lightBlue)

        case .warning:
            print(formattedCurrentTime(), "⚠️ ", message.yellow)

        case .error:
            print(formattedCurrentTime(), "❌ ", message.lightRed)
        }
    }

    private func formattedCurrentTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        let dateTime = dateFormatter.string(from: Date())
        return "\(dateTime):"
    }

    private func xcodeMessage(_ message: String, level: PrintLevel, file: String? = nil, line: Int? = nil, charInLine: Int? = nil) {
        if let location = locationInfo(file: file, line: line, charInLine: charInLine) {
            print(location, "\(level.rawValue): \(Constants.toolName): ", message)
        } else {
            print("\(level.rawValue): \(Constants.toolName): ", message)
        }
    }

    private func locationInfo(file: String?, line: Int?, charInLine: Int?) -> String? {
        guard let file = file else { return nil }
        guard let line = line else { return "\(file): " }
        guard let charInLine = charInLine else { return "\(file):\(line): " }
        return "\(file):\(line):\(charInLine): "
    }
}
