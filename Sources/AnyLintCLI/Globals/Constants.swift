import Foundation

var log = Logger(outputType: .console)

enum Constants {
    static let currentVersion: String = "0.1.0"
    static let commandName: String = "anylint"
    static let defaultConfigurationPath: String = "AnyLint.swift"
    static let initTemplateCases: String = InitTask.Template.allCases.map { $0.rawValue }.joined(separator: ", ")
    static let toolName: String = "AnyLint"
}
