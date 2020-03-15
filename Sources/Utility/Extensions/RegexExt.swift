import Foundation
import HandySwift

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
