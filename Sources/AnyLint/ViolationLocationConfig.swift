import Foundation

public struct ViolationLocationConfig {
    public enum Range {
        case fullMatch
        case captureGroup(index: Int)
    }

    public enum Bound {
        case lower
        case upper
    }

    let range: Range
    let bound: Bound

    public init(range: Range, bound: Bound) {
        self.range = range
        self.bound = bound
    }
}
