import Foundation

enum Constants {
    static let defaultConfigurationPath: String = "AnyLint.swift"
    static let currentVersion: String = "0.1.0"
    static let initTemplateCases: String = InitTask.Template.allCases.map { $0.rawValue }.joined(separator: ", ")
}
