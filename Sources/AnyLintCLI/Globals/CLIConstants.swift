import Foundation

enum CLIConstants {
    static let commandName: String = "anylint"
    static let defaultConfigFileName: String = "lint.swift"
    static let initTemplateCases: String = InitTask.Template.allCases.map { $0.rawValue }.joined(separator: ", ")
    static let swiftShPath: String = "/usr/local/bin/swift-sh"
}
