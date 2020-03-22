import Foundation

/// Information about an autocorrection.
public struct AutoCorrection {
    /// The matching text before applying the autocorrection.
    public let before: String

    /// The matching text after applying the autocorrection.
    public let after: String

    var appliedMessageLines: [String] {
        [
            "Autocorrection applied (before >>> after):",
            "> ✗ \(before.showNewlines())",
            ">>>",
            "> ✓ \(after.showNewlines())",
        ]
    }

    /// Initializes an autocorrection.
    public init(before: String, after: String) {
        self.before = before
        self.after = after
    }
}
