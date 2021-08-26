import Foundation

/// Provides some basic information needed in each lint check.
public struct CheckInfo {
  /// The identifier of the check defined here. Can be used when defining exceptions within files for specific lint checks.
  public let id: String

  /// The hint to be shown as guidance on what the issue is and how to fix it. Can reference any capture groups in the first regex parameter (e.g. `contentRegex`).
  public let hint: String

  /// The severity level for the report in case the check fails.
  public let severity: Severity

  /// Initializes a new info object for the lint check.
  public init(
    id: String,
    hint: String,
    severity: Severity = .error
  ) {
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

extension CheckInfo: Codable {
  public init(
    from decoder: Decoder
  ) throws {
    let container = try decoder.singleValueContainer()
    let rawString = try container.decode(String.self)

    let customSeverityRegex = try Regex(#"^([^@:]+)@([^:]+): ?(.*)$"#)

    if let match = customSeverityRegex.firstMatch(in: rawString) {
      let id = match.captures[0]!
      let severityString = match.captures[1]!
      let hint = match.captures[2]!

      guard let severity = Severity(rawValue: severityString) else {
        log.message(
          "Specified severity '\(severityString)' for check '\(id)' unknown. Use one of [error, warning, info].",
          level: .error
        )
        log.exit(fail: true)
      }

      self = .init(id: id, hint: hint, severity: severity)
    }
    else {
      let defaultSeverityRegex = try Regex(#"^([^@:]+): ?(.*$)"#)

      guard let defaultSeverityMatch = defaultSeverityRegex.firstMatch(in: rawString) else {
        log.message(
          "Could not convert String literal '\(rawString)' to type CheckInfo. Please check the structure to be: <id>(@<severity>): <hint>",
          level: .error
        )
        log.exit(fail: true)
      }

      let id = defaultSeverityMatch.captures[0]!
      let hint = defaultSeverityMatch.captures[1]!

      self = .init(id: id, hint: hint)
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode("\(id)@\(severity.rawValue): \(hint)")
  }
}
