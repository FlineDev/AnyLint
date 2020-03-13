import Foundation
import SwiftCLI
import Utility

enum ValidateOrFail {
    /// Fails if swift-sh is not installed. Returns the install path if it is installed.
    @discardableResult
    static func swiftShInstalled() throws -> String {
        do {
            return try Task.capture(bash: "which \(CLIConstants.swiftShCommand)").stdout
        } catch is CaptureError {
            log.message(
                "\(CLIConstants.swiftShCommand) not installed – please follow instructions on https://github.com/mxcl/swift-sh#installation to install.",
                level: .error
            )
            exit(EXIT_FAILURE)
        }
    }

    static func configFileExists(at configFilePath: String) throws {
        guard fileManager.fileExists(atPath: configFilePath) else {
            log.message(
                "No configuration file found at \(configFilePath) – consider running `\(CLIConstants.commandName) --init` with a template.",
                level: .error
            )
            exit(EXIT_FAILURE)
        }
    }
}
