import Foundation
import SwiftCLI
import Utility

struct LintTask {
    let configFilePath: String
    let logDebugLevel: Bool
    let failOnWarnings: Bool
    let validateOnly: Bool
}

extension LintTask: TaskHandler {
    enum LintError: Error {
        case configFileFailed
    }

    /// - Throws: `LintError.configFileFailed` if running a configuration file fails
    func perform() throws {
        try ValidateOrFail.configFileExists(at: configFilePath)

        if !fileManager.isExecutableFile(atPath: configFilePath) {
            try Task.run(bash: "chmod +x '\(configFilePath)'")
        }

        ValidateOrFail.swiftShInstalled()

        do {
            if fileManager.fileExists(atPath: Constants.statisticsDumpFilePath) {
                log.message("Removing statistics dump file from previous run ...", level: .info)
                try fileManager.removeItem(atPath: Constants.statisticsDumpFilePath)
            }

            log.message("Start linting using config file at \(configFilePath) ...", level: .info)

            var command = "\(configFilePath.absolutePath) \(log.outputType.rawValue)"

            if logDebugLevel {
                command += " \(Constants.debugArgument)"
            }

            if failOnWarnings {
                command += " \(Constants.strictArgument)"
            }

            if validateOnly {
                command += " \(Constants.validateArgument)"
            }

            try Task.run(bash: command)
            log.message("Linting successful using config file at \(configFilePath). Congrats! 🎉", level: .success)
        } catch is RunError {
            if log.outputType != .xcode {
                log.message("Linting failed using config file at \(configFilePath).", level: .error)
            }

            throw LintError.configFileFailed
        }
    }
}
