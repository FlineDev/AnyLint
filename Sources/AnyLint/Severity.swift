import Foundation
import Utility

/// Defines the severity of a lint check.
public enum Severity: Int, CaseIterable {
   /// Use for checks that are mostly informational and not necessarily problematic.
   case info

   /// Use for checks that might potentially be problematic.
   case warning

   /// Use for checks that probably are problematic.
   case error

   var logLevel: Logger.PrintLevel {
      switch self {
      case .info:
         return .info

      case .warning:
         return .warning

      case .error:
         return .error
      }
   }

   static func from(string: String) -> Severity? {
      switch string {
      case "info", "i":
         return .info

      case "warning", "w":
         return .warning

      case "error", "e":
         return .error

      default:
         return nil
      }
   }
}

extension Severity: Comparable {
   public static func < (lhs: Severity, rhs: Severity) -> Bool {
      lhs.rawValue < rhs.rawValue
   }
}
