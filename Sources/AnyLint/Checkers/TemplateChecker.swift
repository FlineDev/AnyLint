import Foundation
import Utility

/// The source of the subchecks to run.
public enum CheckSource {
    /// The device-local source, requiring a path String.
    case local(String)

    /// A remote public URL source, requiring the full config file URL string.
    case remote(String)

    /// A GitHub repo with a 'Variants' folder, requiring the GitHub user, repo , branch/tag and variant.
    case github(user: String, repo: String, branchOrTag: String, variant: String)
}

struct TemplateChecker {
    let source: CheckSource
    let runOnly: [String]?
    let exclude: [String]?
}

extension TemplateChecker: Checker {
    func performCheck() throws -> [CheckInfo: [Violation]] {
        var correctedSource: CheckSource = source

        if let remoteSource = convertGitHubToRemoteSource(source: correctedSource) {
            correctedSource = remoteSource
        }

        if let localSource = try downloadRemoteSourceToLocal(source: correctedSource) {
            correctedSource = localSource
        }

        guard case let .local(templateFilePath) = correctedSource else {
            log.message("Found unexpected state while validating checks source.", level: .error)
            log.exit(status: .failure)
            return [:] // only reachable in unit tests
        }

        // TODO: [cg_2020-06-14] not yet implemented

        log.message("Local template file to run: '\(templateFilePath)'", level: .info)

        return [:]
    }

    private func convertGitHubToRemoteSource(source: CheckSource) -> CheckSource? {
        guard case let .github(user, repo, branchOrTag, variant) = source else { return nil }
        return .remote("https://raw.githubusercontent.com/\(user)/\(repo)/\(branchOrTag)/Variants/\(variant).swift")
    }

    private func downloadRemoteSourceToLocal(source: CheckSource) throws -> CheckSource? {
        guard case let .remote(urlString) = source else { return nil }
        guard let remoteUrl = URL(string: urlString) else {
            log.message("`.remote` source URL string '\(urlString)' is not a valid URL.", level: .error)
            log.exit(status: .failure)
            return nil // only reachable in unit tests
        }

        let remoteFileContents = try String(contentsOf: remoteUrl)
        let uniqueFileName = remoteUrl
            .deletingPathExtension()
            .pathComponents
            .filter { $0 != "Variants" && $0 != "/" }
            .suffix(4)
            .joined(separator: "_")
        let localFilePath = "\(Constants.tempDirPath)/\(uniqueFileName).swift"

        if !fileManager.fileExists(atPath: Constants.tempDirPath) {
            try fileManager.createDirectory(atPath: Constants.tempDirPath, withIntermediateDirectories: true, attributes: nil)
        }

        try remoteFileContents.write(toFile: localFilePath, atomically: true, encoding: .utf8)

        return .local(localFilePath)
    }
}
