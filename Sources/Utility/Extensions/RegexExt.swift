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
