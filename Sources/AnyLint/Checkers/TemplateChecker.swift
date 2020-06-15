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

    /// A GitHub repo source config file specified via repo (e.g. 'Flinesoft/AnyLint-Swift'), version (tag or branch) and variant (a subpath to the config file).
    case github(repo: String, version: String, variant: String)
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

        log.message("Running local config file at '\(templateFilePath)'", level: .info)

        var command = templateFilePath.absolutePath
        if logDebugLevel {
            command += " \(Constants.debugArgument)"
        }
        try Task.run(bash: command)

        let dumpFileUrl = URL(fileURLWithPath: Constants.statisticsDumpFilePath)

        guard
            let dumpFileData = try? Data(contentsOf: dumpFileUrl),
            let dumpedStatistics = try? JSONDecoder().decode(Statistics.self, from: dumpFileData)
        else {
            log.message("Could not decode Statistics JSON at \(dumpFileUrl.path)", level: .error)
            log.exit(status: .failure)
            return [:] // only reachable in unit tests
        }

        try fileManager.removeItem(atPath: Constants.statisticsDumpFilePath)
        return dumpedStatistics.violationsPerCheck
    }

    private func convertGitHubToRemoteSource(source: CheckSource) -> CheckSource? {
        guard case let .github(repo, version, variant) = source else { return nil }
        log.message("Converting .github source to .remote source ...", level: .debug)
        return .remote("https://raw.githubusercontent.com/\(repo)/\(version)/\(variant).swift")
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
        let uniqueFileName = (
            remoteUrl.pathComponents.dropFirst().prefix(2) + remoteUrl.deletingPathExtension().pathComponents.suffix(2)
        ).joined(separator: "_")
        let localFilePath = "\(Constants.tempDirPath)/\(uniqueFileName).swift"

        if !fileManager.fileExists(atPath: Constants.tempDirPath) {
            try fileManager.createDirectory(atPath: Constants.tempDirPath, withIntermediateDirectories: true, attributes: nil)
        }

        try remoteFileContents.write(toFile: localFilePath, atomically: true, encoding: .utf8)

        return .local(localFilePath)
    }
}
