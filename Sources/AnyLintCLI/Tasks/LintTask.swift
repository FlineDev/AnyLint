import Foundation
import SwiftCLI

struct LintTask {
    let configFilePath: String
}

extension LintTask: TaskHandler {
    func perform() throws {
        guard fileManager.fileExists(atPath: configFilePath) else {
            log.message(
                "No configuration file found at \(configFilePath) – consider running `\(Constants.commandName) --init` with a template.",
                level: .error
            )
            exit(EXIT_FAILURE)
        }

        if !fileManager.isExecutableFile(atPath: configFilePath) {
            try Task.run(bash: "chmod +x '\(configFilePath)'")
        }

        do {
            try Task.run(bash: "which swift-sh")
        } catch is RunError {
            log.message("swift-sh not installed – please follow instructions on https://github.com/mxcl/swift-sh#installation to install.", level: .error)
            exit(EXIT_FAILURE)
        }

        do {
            log.message("Start linting using config file at \(configFilePath) ...", level: .info)
            try Task.run(bash: "\(configFilePath.absolutePath)")
            log.message("Successfully linted without errors using config file at \(configFilePath). Congrats! 🎉", level: .success)
        } catch is RunError {
            log.message("Linting failed using config file at \(configFilePath).", level: .error)
            exit(EXIT_FAILURE)
        }
    }
}
