import Foundation
import SwiftCLI
import Utility

class SingleCommand: Command {
   // MARK: - Basics
   var name: String = CLIConstants.commandName
   var shortDescription: String = "Lint anything by combining the power of Swift & regular expressions."

   // MARK: - Subcommands
   @Flag("-v", "--version", description: "Prints the current tool version")
   var version: Bool

   @Flag("-x", "--xcode", description: "Prints warnings & errors in a format to be reported right within Xcodes left sidebar")
   var xcode: Bool

   @Flag("-d", "--debug", description: "Logs much more detailed information about what AnyLint is doing for debugging purposes")
   var debug: Bool

   @Flag("-s", "--strict", description: "Fails on warnings as well - by default, the command only fails on errors)")
   var strict: Bool

   @Flag("-l", "--validate", description: "Runs only validations for `matchingExamples`, `nonMatchingExamples` and `autoCorrectExamples`.")
   var validate: Bool

   @Flag("-u", "--unvalidated", description: "Runs the checks without validating their correctness. Only use for faster subsequent runs after a validated run succeeded.")
   var unvalidated: Bool

   @Flag("-m", "--measure", description: "Prints the time it took to execute each check for performance optimizations")
   var measure: Bool

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

      log.logDebugLevel = debug

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
            try LintTask(
               configFilePath: configPath,
               logDebugLevel: self.debug,
               failOnWarnings: self.strict,
               validateOnly: self.validate,
               unvalidated: self.unvalidated,
               measure: self.measure
            ).perform()
         } catch LintTask.LintError.configFileFailed {
            anyConfigFileFailed = true
         }
      }
      exit(anyConfigFileFailed ? EXIT_FAILURE : EXIT_SUCCESS)
   }
}
