import Foundation

extension Regex: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        do {
            self = try Regex(value)
        } catch {
            log.message("Failed to convert String literal '\(value)' to type Regex.", level: .error)
            log.exit(status: .failure)
            exit(EXIT_FAILURE) // only reachable in unit tests
        }
    }
}

extension Regex: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, String)...) {
        do {
            self = try Regex(elements.reduce(into: "") { result, element in result.append("(?<\(element.0)>\(element.1))") })
        } catch {
            log.message("Failed to convert Dictionary literal '\(elements)' to type Regex.", level: .error)
            log.exit(status: .failure)
            exit(EXIT_FAILURE) // only reachable in unit tests
        }
    }
}

extension Regex {
    /// Replaces all captures groups with the given capture references. References can be numbers like `$1` and capture names like `$prefix`.
    public func replaceAllCaptures(in input: String, with template: String) -> String {
        replacingMatches(in: input, with: numerizedNamedCaptureRefs(in: template))
    }

    /// Numerizes references to named capture groups to work around missing named capture group replacement in `NSRegularExpression` APIs.
    func numerizedNamedCaptureRefs(in replacementString: String) -> String {
        let captureGroupNameRegex = Regex(#"\(\?\<([a-zA-Z0-9_-]+)\>[^\)]+\)"#)
        let captureGroupNames: [String] = captureGroupNameRegex.matches(in: pattern).map { $0.captures[0]! }
        return captureGroupNames.enumerated().reduce(replacementString) { result, enumeratedGroupName in
            result.replacingOccurrences(of: "$\(enumeratedGroupName.element)", with: "$\(enumeratedGroupName.offset + 1)")
        }
    }
}
