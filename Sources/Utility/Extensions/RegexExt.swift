import Foundation
import HandySwift

extension Regex: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        do {
            self = try Regex(value)
        } catch {
            log.message("Failed to convert String literal '\(value)' to type Regex.", level: .error)
            exit(EXIT_FAILURE)
        }
    }
}
