import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import SwiftCLI
import Utility

/// The source of the subchecks to run.
public enum CheckSource {
    /// The device-local source, requiring a path String.
    case local(String)

    /// A remote public URL source, requiring the full config file URL string.
    case remote(String)

    /// A GitHub repo with a 'Variants' folder, requiring the GitHub user, repo, branch/tag, subpath and variant.
    case github(user: String, repo: String, branchOrTag: String, subpath: String, variant: String)
}

struct TemplateChecker {
    let source: CheckSource
    let runOnly: [String]?
    let exclude: [String]?
    let logDebugLevel: Bool
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

        if !fileManager.isExecutableFile(atPath: templateFilePath) {
            try Task.run(bash: "chmod +x '\(templateFilePath)'")
        }

        log.message("Local template file to run: '\(templateFilePath)'", level: .info)

        var command = templateFilePath.absolutePath
        if logDebugLevel {
            command += " \(Constants.debugArgument)"
        }
        try Task.run(bash: command)

        // TODO: [cg_2020-06-15] parse results JSON output and add to statistics
        return [:]
    }

    private func convertGitHubToRemoteSource(source: CheckSource) -> CheckSource? {
        guard case let .github(user, repo, branchOrTag, subpath, variant) = source else { return nil }
        log.message("Converting .github source to .remote source ...", level: .debug)
        return .remote("https://raw.githubusercontent.com/\(user)/\(repo)/\(branchOrTag)/\(subpath)/\(variant).swift")
    }

    private func downloadRemoteSourceToLocal(source: CheckSource) throws -> CheckSource? {
        guard case let .remote(urlString) = source else { return nil }

        log.message("Downloading .remote source from '\(urlString)' ...", level: .debug)
        guard let remoteUrl = URL(string: urlString) else {
            log.message("`.remote` source URL string '\(urlString)' is not a valid URL.", level: .error)
            log.exit(status: .failure)
            return nil // only reachable in unit tests
        }

        let remoteFileContents = try String(contentsOf: remoteUrl)
        let uniqueFileName = (remoteUrl.pathComponents.dropFirst().prefix(2) + [remoteUrl.deletingPathExtension().lastPathComponent]).joined(separator: "_")
        let localFilePath = "\(Constants.tempDirPath)/\(uniqueFileName).swift"

        if !fileManager.fileExists(atPath: Constants.tempDirPath) {
            try fileManager.createDirectory(atPath: Constants.tempDirPath, withIntermediateDirectories: true, attributes: nil)
        }

        try remoteFileContents.write(toFile: localFilePath, atomically: true, encoding: .utf8)

        return .local(localFilePath)
    }
}
