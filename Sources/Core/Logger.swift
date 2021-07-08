import Foundation
import Rainbow

/// Shortcut to access the `Logger` within this project.
public var log = Logger(outputFormat: .commandLine)

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

  /// The output format of the logger.
  public let outputFormat: OutputFormat

  /// Initializes a new Logger object with a given output format.
  public init(
    outputFormat: OutputFormat
  ) {
    self.outputFormat = outputFormat
  }

  /// Communicates a message to the chosen output target with proper formatting based on level & source.
  ///
  /// - Parameters:
  ///   - message: The message to be printed. Don't include `Error!`, `Warning!` or similar information at the beginning.
  ///   - level: The level of the print statement.
  public func message(_ message: String, level: PrintLevel) {
    switch outputFormat {
    case .commandLine, .json:
      consoleMessage(message, level: level)

    case .xcode:
      xcodeMessage(message, level: level)
    }
  }

  /// Exits the current program with the given fail state.
  public func exit(fail: Bool) {
    let statusCode = fail ? EXIT_FAILURE : EXIT_SUCCESS

    #if os(Linux)
      Glibc.exit(statusCode)
    #else
      Darwin.exit(statusCode)
    #endif
  }

  private func consoleMessage(_ message: String, level: PrintLevel) {
    switch level {
    case .success:
      print(formattedCurrentTime(), "✅", message.green)

    case .info:
      print(formattedCurrentTime(), "ℹ️ ", message.lightBlue)

    case .warning:
      print(formattedCurrentTime(), "⚠️ ", message.yellow)

    case .error:
      print(formattedCurrentTime(), "❌", message.red)
    }
  }

  /// Reports a message in an Xcode compatible format to be shown in the left pane.
  ///
  /// - Parameters:
  ///   - message: The message to be printed. Don't include `Error!`, `Warning!` or similar information at the beginning.
  ///   - level: The level of the print statement.
  ///   - location: The file, line and char in line location string.
  public func xcodeMessage(_ message: String, level: PrintLevel, location: String? = nil) {
    var locationPrefix = ""

    if let location = location {
      locationPrefix = location + " "
    }

    print("\(locationPrefix)\(level.rawValue): AnyLint: \(message)")
  }

  private func formattedCurrentTime() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss.SSS"
    let dateTime = dateFormatter.string(from: Date())
    return "\(dateTime):"
  }
}

extension Severity {
  public var logLevel: Logger.PrintLevel {
    switch self {
    case .info:
      return .info

    case .warning:
      return .warning

    case .error:
      return .error
    }
  }
}
