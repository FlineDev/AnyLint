import Foundation

/// Helper to log output optimized for Xcode.
public final class XcodeLogger: Loggable {
  /// Reports a message in an Xcode compatible format to be shown in the left pane.
  ///
  /// - Parameters:
  ///   - message: The message to be printed. Don't include `Error!`, `Warning!` or similar information at the beginning.
  ///   - level: The level of the print statement.
  ///   - location: The file, line and char in line location string.
  public func message(_ message: String, level: PrintLevel, location: Location?) {
    var locationPrefix = ""

    if let location = location {
      locationPrefix = location.locationMessage(pathType: .absolute) + " "
    }

    print("\(locationPrefix)\(level.rawValue): AnyLint: \(message)")
  }
}
