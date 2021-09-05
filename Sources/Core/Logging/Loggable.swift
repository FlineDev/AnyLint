import Foundation

/// Shortcut to access the `Logger` within this project.
public var log: Loggable = ConsoleLogger()

public protocol Loggable {
  func message(_ message: String, level: PrintLevel, fileLocation: Location?)
}

extension Loggable {
  /// Exits the current program with the given fail state.
  public func exit(fail: Bool) -> Never {
    let statusCode = fail ? EXIT_FAILURE : EXIT_SUCCESS

    #if os(Linux)
      Glibc.exit(statusCode)
    #else
      Darwin.exit(statusCode)
    #endif
  }

  /// Convenience overload of `message(:level:fileLocation:)` with `fileLocation` set to `nil`.
  public func message(_ message: String, level: PrintLevel) {
    self.message(message, level: level, fileLocation: nil)
  }
}
