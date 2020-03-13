import Foundation
import SwiftCLI
import Utility

struct EditTask {
    let configFilePath: String
}

extension EditTask: TaskHandler {
    func perform() throws {
        try ValidateOrFail.configFileExists(at: configFilePath)
        try ValidateOrFail.swiftShInstalled()

        log.message("Opening config file at \(configFilePath) in Xcode to edit ...", level: .info)
        try Task.run(bash: "\(CLIConstants.swiftShCommand) edit '\(configFilePath)'")
    }
}
