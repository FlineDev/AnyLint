import Foundation

let fileManager = FileManager.default
var log = Logger(outputType: .console)

enum Constants {
    static let currentVersion: String = "0.1.0"
    static let commandName: String = "anylint"
    static let defaultConfigFileName: String = "lint.swift"
    static let initTemplateCases: String = InitTask.Template.allCases.map { $0.rawValue }.joined(separator: ", ")
    static let toolName: String = "AnyLint"
}
