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

      /// Print detailed information for debugging purposes.
      case debug

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

         case .debug:
            return Color.default
         }
      }
   }

   /// The output type.
   public enum OutputType: String {
      /// Output is targeted to a console to be read by developers.
      case console

      /// Output is targeted to Xcodes left pane to be interpreted by it to mark errors & warnings.
      case xcode

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

   /// The output type of the logger.
   public let outputType: OutputType

   /// Defines if the log should include debug logs.
   public var logDebugLevel: Bool = false

   /// Initializes a new Logger object with a given output type.
   public init(outputType: OutputType) {
      self.outputType = outputType
   }

   /// Communicates a message to the chosen output target with proper formatting based on level & source.
   ///
   /// - Parameters:
   ///   - message: The message to be printed. Don't include `Error!`, `Warning!` or similar information at the beginning.
   ///   - level: The level of the print statement.
   public func message(_ message: String, level: PrintLevel) {
      guard level != .debug || logDebugLevel else { return }

      switch outputType {
      case .console:
         consoleMessage(message, level: level)

      case .xcode:
         xcodeMessage(message, level: level)

      case .test:
         TestHelper.shared.consoleOutputs.append((message, level))
      }
   }

   /// Exits the current program with the given status.
   public func exit(status: ExitStatus) {
      switch outputType {
      case .console, .xcode:
         #if os(Linux)
            Glibc.exit(status.statusCode)
         #else
            Darwin.exit(status.statusCode)
         #endif

      case .test:
         TestHelper.shared.exitStatus = status
      }
   }

   private func consoleMessage(_ message: String, level: PrintLevel) {
      switch level {
      case .success:
         print(formattedCurrentTime(), "✅", message.green)

      case .info:
         print(formattedCurrentTime(), "ℹ️ ", message.lightCyan)

      case .warning:
         print(formattedCurrentTime(), "⚠️ ", message.yellow)

      case .error:
         print(formattedCurrentTime(), "❌", message.red)

      case .debug:
         print(formattedCurrentTime(), "💬", message)
      }
   }

   /// Reports a message in an Xcode compatible format to be shown in the left pane.
   ///
   /// - Parameters:
   ///   - message: The message to be printed. Don't include `Error!`, `Warning!` or similar information at the beginning.
   ///   - level: The level of the print statement.
   ///   - location: The file, line and char in line location string.
   public func xcodeMessage(_ message: String, level: PrintLevel, location: String? = nil) {
      if let location = location {
         print("\(location) \(level.rawValue): \(Constants.toolName): \(message)")
      } else {
         print("\(level.rawValue): \(Constants.toolName): \(message)")
      }
   }

   private func formattedCurrentTime() -> String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "HH:mm:ss.SSS"
      let dateTime = dateFormatter.string(from: Date())
      return "\(dateTime):"
   }
}
