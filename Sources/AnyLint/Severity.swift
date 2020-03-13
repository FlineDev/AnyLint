import Foundation

/// Defines the severity of a lint check.
public enum Severity {
    /// Use for checks that are mostly informational and not necessarily problematic.
    case info

    /// Use for checks that might potentially be problematic.
    case warning

    /// Use for checks that probably are problematic.
    case error
}
