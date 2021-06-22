import Foundation

enum CLIConstants {
    static let commandName: String = "anylint"
    static let defaultConfigFileName: String = "anylint.yml"
    static let initTemplateCases: String = InitTask.Template.allCases.map { $0.rawValue }.joined(separator: ", ")
}
