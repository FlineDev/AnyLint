import Foundation
import Utility

/// Information about an autocorrection.
public struct AutoCorrection {
    /// The matching text before applying the autocorrection.
    public let before: String

    /// The matching text after applying the autocorrection.
    public let after: String

    var appliedMessageLines: [String] {
        [
            "Autocorrection applied (before >>> after):",
            "> ✗ \(before.showWhitespacesAndNewlines())",
            ">>>",
            "> ✓ \(after.showWhitespacesAndNewlines())",
        ]
    }

    /// Initializes an autocorrection.
    public init(before: String, after: String) {
        self.before = before
        self.after = after
    }
}

extension AutoCorrection: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, String)...) {
        guard
            let before = elements.first(where: { $0.0 == "before" })?.1,
            let after = elements.first(where: { $0.0 == "after" })?.1
        else {
            log.message("Failed to convert Dictionary literal '\(elements)' to type AutoCorrection.", level: .error)
            log.exit(status: .failure)
            exit(EXIT_FAILURE) // only reachable in unit tests
        }

        self = AutoCorrection(before: before, after: after)
    }
}
