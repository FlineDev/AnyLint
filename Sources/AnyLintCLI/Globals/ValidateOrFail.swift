import Foundation

enum ValidateOrFail {
  static func configFileExists(at configFilePath: String) throws {
    guard fileManager.fileExists(atPath: configFilePath) else {
      log.message(
        "No configuration file found at \(configFilePath) – consider running `\(CLIConstants.commandName) --init` with a template.",
        level: .error
      )
      log.exit(status: .failure)
      return  // only reachable in unit tests
    }
  }
}
