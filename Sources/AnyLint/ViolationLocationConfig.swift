import Foundation

/// Configuration for the position of the violation marker violations should be reported at.
public struct ViolationLocationConfig {
    /// The range to use for pointer reporting. One of `.fullMatch` or `.captureGroup(index:)`.
    public enum Range {
        /// Uses the full matched range of the Regex.
        case fullMatch

        /// Uses the capture group range of the provided index.
        case captureGroup(index: Int)
    }

    /// The bound to use for pionter reporting. One of `.lower` or `.upper`.
    public enum Bound {
        /// Uses the lower end of the provided range.
        case lower

        /// Uses the upper end of the provided range.
        case upper
    }

    let range: Range
    let bound: Bound

    /// Initializes a new instance with given range and bound.
    /// - Parameters:
    ///   - range: The range to use for pointer reporting. One of `.fullMatch` or `.captureGroup(index:)`.
    ///   - bound: The bound to use for pionter reporting. One of `.lower` or `.upper`.
    public init(range: Range, bound: Bound) {
        self.range = range
        self.bound = bound
    }
}
