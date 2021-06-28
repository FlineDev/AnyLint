import Foundation
import AppKit

/// Defines the severity of a lint check.
public enum Severity: String, CaseIterable {
  /// Use for checks that are mostly informational and not necessarily problematic.
  case info

  /// Use for checks that might potentially be problematic.
  case warning

  /// Use for checks that probably are problematic.
  case error
//
//  static func from(string: String) -> Severity? {
//    switch string {
//    case "info", "i":
//      return .info
//
//    case "warning", "w":
//      return .warning
//
//    case "error", "e":
//      return .error
//
//    default:
//      return nil
//    }
//  }
}
//
//extension Severity: Comparable {
//  public static func < (lhs: Severity, rhs: Severity) -> Bool {
//    switch (lhs, rhs) {
//    case (.info, .warning), (.warning, .error), (.info, .error):
//      return true
//
//    default:
//      return false
//    }
//  }
//}

