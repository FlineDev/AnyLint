import Foundation
import SwiftCLI
import Utility

struct LintTask {
    let configFilePath: String
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

        try ValidateOrFail.swiftShInstalled()

        do {
            log.message("Start linting using config file at \(configFilePath) ...", level: .info)
            try Task.run(bash: "\(configFilePath.absolutePath)")
            log.message("Successfully linted without errors using config file at \(configFilePath). Congrats! 🎉", level: .success)
        } catch is RunError {
            log.message("Linting failed using config file at \(configFilePath).", level: .error)
            throw LintError.configFileFailed
        }
    }
}
