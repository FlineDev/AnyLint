import Foundation
import Rainbow

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
