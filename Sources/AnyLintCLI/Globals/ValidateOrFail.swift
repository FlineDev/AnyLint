import Foundation
import SwiftCLI
import Utility

enum ValidateOrFail {
    /// Fails if swift-sh is not installed.
    static func swiftShInstalled() {
        guard fileManager.fileExists(atPath: CLIConstants.swiftShPath) else {
            log.message(
                "swift-sh not installed – please follow instructions on https://github.com/mxcl/swift-sh#installation to install.",
                level: .error
            )
            log.exit(status: .failure)
            return // only reachable in unit tests
        }
    }

    static func configFileExists(at configFilePath: String) throws {
        guard fileManager.fileExists(atPath: configFilePath) else {
            log.message(
                "No configuration file found at \(configFilePath) – consider running `\(CLIConstants.commandName) --init` with a template.",
                level: .error
            )
            log.exit(status: .failure)
            return // only reachable in unit tests
        }
    }
}
