import Foundation

/// Shortcut to access the default `FileManager` within this project.
public let fileManager = FileManager.default

/// Shortcut to access the `Logger` within this project.
public var log = Logger(outputType: .console)

/// Constants to reference across the project.
public enum Constants {
    /// The current tool version string. Conforms to SemVer 2.0.
    public static let currentVersion: String = "0.9.1"

    /// The name of this tool.
    public static let toolName: String = "AnyLint"

    /// The debug mode argument for command line pass-through.
    public static let debugArgument: String = "debug"

    /// The strict mode argument for command-line pass-through.
    public static let strictArgument: String = "strict"

    /// The validate-only mode argument for command-line pass-through.
    public static let validateArgument: String = "validate"

    /// The separator indicating that next come regex options.
    public static let regexOptionsSeparator: String = #"\"#

    /// Hint that the case insensitive option should be active on a Regex.
    public static let caseInsensitiveRegexOption: String = "i"

    /// Hint that the case dot matches newline option should be active on a Regex.
    public static let dotMatchesNewlinesRegexOption: String = "m"

    /// The number of newlines required in both before and after of AutoCorrections required to use diff for outputs.
    public static let newlinesRequiredForDiffing: Int = 3
}
