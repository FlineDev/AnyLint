import Foundation
import SwiftCLI

class SingleCommand: Command {
    // MARK: - Basics
    var name: String = Constants.commandName
    var shortDescription: String = "Lint anything by combining the power of Swift & regular expressions."

    // MARK: - Subcommands
    @Flag("-v", "--version", description: "Print the current tool version")
    var version: Bool

    @Key("-i", "--init", description: "Configure AnyLint with a default template. Has to be one of: [\(Constants.initTemplateCases)]")
    var initTemplateName: String?

    // MARK: - Options
    @VariadicKey("-p", "--path", description: "Provide a custom path to the config file (multiple usage supported)")
    var customPaths: [String]

    // MARK: - Execution
    func execute() throws {
        // version subcommand
        if version {
            VersionTask().perform()
            exit(EXIT_SUCCESS)
        }

        let configurationPaths = customPaths.isEmpty ? [Constants.defaultConfigurationPath] : customPaths

        // init subcommand
        if let initTemplateName = initTemplateName {
            guard let initTemplate = InitTask.Template(rawValue: initTemplateName) else {
                log.message("Unknown default template '\(initTemplateName)' – use one of: [\(Constants.initTemplateCases)]", level: .error)
                exit(EXIT_FAILURE)
            }

            for path in configurationPaths {
                InitTask(path: path, template: initTemplate).perform()
            }
            exit(EXIT_SUCCESS)
        }

        // lint command
        for path in configurationPaths {
            LintTask(path: path).perform()
        }
        exit(EXIT_SUCCESS)
    }
}
