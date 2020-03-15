import Foundation
import SwiftCLI
import Utility

struct InitTask {
    enum Template: String, CaseIterable {
        case blank
        case ios
        case android

        var configFileContents: String {
            switch self {
            case .blank:
                return BlankTemplate.fileContents()

            case .android:
                return AndroidTemplate.fileContents()

            case .ios:
                return IOSTemplate.fileContents()
            }
        }
    }

    let configFilePath: String
    let template: Template
}

extension InitTask: TaskHandler {
    func perform() throws {
        guard !fileManager.fileExists(atPath: configFilePath) else {
            log.message("Configuration file already exists at path '\(configFilePath)'.", level: .error)
            log.exit(status: .failure)
            return // only reachable in unit tests
        }

        log.message("Making sure config file directory exists ...", level: .info)
        try Task.run(bash: "mkdir -p '\(configFilePath.parentDirectoryPath)'")

        log.message("Creating config file using template '\(template.rawValue)' ...", level: .info)
        fileManager.createFile(
            atPath: configFilePath,
            contents: template.configFileContents.data(using: .utf8),
            attributes: nil
        )

        log.message("Making config file executable ...", level: .info)
        try Task.run(bash: "chmod +x '\(configFilePath)'")

        log.message("Successfully created config file at \(configFilePath)", level: .success)
    }
}
