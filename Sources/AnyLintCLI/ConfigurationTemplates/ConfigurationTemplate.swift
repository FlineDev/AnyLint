import Foundation
import Utility

protocol ConfigurationTemplate {
    static func fileContents() -> String
}

extension ConfigurationTemplate {
    static var commonPrefix: String {
        "#!\(CLIConstants.swiftShPath)\nimport AnyLint // @Flinesoft ~> \(Constants.currentVersion)\n\n"
    }

    static var commonSuffix: String {
        "\n\n// MARK: - Log Summary & Exit\nLint.logSummaryAndExit(arguments: CommandLine.arguments)\n"
    }
}
