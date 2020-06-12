import Foundation

/// The source of the subchecks to run.
public enum CheckSource {
    /// The device-local source, requiring a path String.
    case local(String)

    /// A remote public URL source, requiring the URL string.
    case remote(String)

    /// Predefined and officially supported community projects providing different variants of checks.
    case community(String, variant: String)
}

struct TemplateChecker {
    let source: CheckSource
    let runOnly: [String]?
    let exclude: [String]?
    let options: [String: Codable]?
}

extension TemplateChecker: Checker {
    func performCheck() throws -> [CheckInfo: [Violation]] {
        // TODO: [cg_2020-06-13] not yet implemented
        return [:]
    }
}
