import Foundation
import Utility

/// Provides some basic information needed in each lint check.
public struct CheckInfo {
   /// The identifier of the check defined here. Can be used when defining exceptions within files for specific lint checks.
   public let id: String

   /// The hint to be shown as guidance on what the issue is and how to fix it. Can reference any capture groups in the first regex parameter (e.g. `contentRegex`).
   public let hint: String

   /// The severity level for the report in case the check fails.
   public let severity: Severity

   /// Initializes a new info object for the lint check.
   public init(id: String, hint: String, severity: Severity = .warning) {
      self.id = id
      self.hint = hint
      self.severity = severity
   }
}

extension CheckInfo: Hashable {
   public func hash(into hasher: inout Hasher) {
      hasher.combine(id)
   }
}

extension CheckInfo: CustomStringConvertible {
   public var description: String {
      "check '\(id)'"
   }
}

extension CheckInfo: ExpressibleByStringLiteral {
   public init(stringLiteral value: String) {
      let customSeverityRegex: Regex = [
         "id": #"^[^@:]+"#,
         "severitySeparator": #"@"#,
         "severity": #"[^:]+"#,
         "hintSeparator": #": ?"#,
         "hint": #".*$"#,
      ]

      if let customSeverityMatch = customSeverityRegex.firstMatch(in: value) {
         let id = customSeverityMatch.captures[0]!
         let severityString = customSeverityMatch.captures[2]!
         let hint = customSeverityMatch.captures[4]!

         guard let severity = Severity.from(string: severityString) else {
            log.message("Specified severity '\(severityString)' for check '\(id)' unknown. Use one of [error, warning, info].", level: .error)
            log.exit(status: .failure)
            exit(EXIT_FAILURE) // only reachable in unit tests
         }

         self = CheckInfo(id: id, hint: hint, severity: severity)
      } else {
         let defaultSeverityRegex: Regex = [
            "id": #"^[^@:]+"#,
            "hintSeparator": #": ?"#,
            "hint": #".*$"#,
         ]

         guard let defaultSeverityMatch = defaultSeverityRegex.firstMatch(in: value) else {
            log.message(
               "Could not convert String literal '\(value)' to type CheckInfo. Please check the structure to be: <id>(@<severity>): <hint>",
               level: .error
            )
            log.exit(status: .failure)
            exit(EXIT_FAILURE) // only reachable in unit tests
         }

         let id = defaultSeverityMatch.captures[0]!
         let hint = defaultSeverityMatch.captures[2]!

         self = CheckInfo(id: id, hint: hint)
      }
   }
}
