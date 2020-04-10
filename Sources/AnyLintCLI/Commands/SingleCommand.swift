import Foundation
import SwiftCLI
import Utility

class SingleCommand: Command {
    // MARK: - Basics
    var name: String = CLIConstants.commandName
    var shortDescription: String = "Lint anything by combining the power of Swift & regular expressions."

    // MARK: - Subcommands
    @Flag("-v", "--version", description: "Print the current tool version")
    var version: Bool

    @Flag("-x", "--xcode", description: "Print warnings & errors in a format to be reported right within Xcodes left sidebar")
    var xcode: Bool

    @Key("-i", "--init", description: "Configure AnyLint with a default template. Has to be one of: [\(CLIConstants.initTemplateCases)]")
    var initTemplateName: String?

    // MARK: - Options
    @VariadicKey("-p", "--path", description: "Provide a custom path to the config file (multiple usage supported)")
    var customPaths: [String]

    // MARK: - Execution
    func execute() throws {
        if xcode {
            log = Logger(outputType: .xcode)
        }

        // version subcommand
        if version {
            try VersionTask().perform()
            log.exit(status: .success)
        }

        let configurationPaths = customPaths.isEmpty
            ? [fileManager.currentDirectoryPath.appendingPathComponent(CLIConstants.defaultConfigFileName)]
            : customPaths

        // init subcommand
        if let initTemplateName = initTemplateName {
            guard let initTemplate = InitTask.Template(rawValue: initTemplateName) else {
                log.message("Unknown default template '\(initTemplateName)' – use one of: [\(CLIConstants.initTemplateCases)]", level: .error)
                log.exit(status: .failure)
                return // only reachable in unit tests
            }

            for configPath in configurationPaths {
                try InitTask(configFilePath: configPath, template: initTemplate).perform()
            }
            log.exit(status: .success)
        }

        // lint main command
        var anyConfigFileFailed = false
        for configPath in configurationPaths {
            do {
                try LintTask(configFilePath: configPath).perform()
            } catch LintTask.LintError.configFileFailed {
                anyConfigFileFailed = true
            }
        }
        exit(anyConfigFileFailed ? EXIT_FAILURE : EXIT_SUCCESS)
    }
}
