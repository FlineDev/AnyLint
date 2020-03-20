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
    public init(id: String, hint: String, severity: Severity = .error) {
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
