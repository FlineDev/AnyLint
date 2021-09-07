import Foundation

/// Helper to log output to console.
public final class ConsoleLogger: Loggable {
  /// Communicates a message to console with proper formatting based on level & source.
  ///
  /// - Parameters:
  ///   - message: The message to be printed. Don't include `Error!`, `Warning!` or similar information at the beginning.
  ///   - level: The level of the print statement.
  ///   - location: The file, line and char in line location string.
  public func message(_ message: String, level: PrintLevel, location: Location?) {
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

  private func formattedCurrentTime() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss.SSS"
    let dateTimeString = dateFormatter.string(from: Date())
    return "\(dateTimeString):"
  }
}
