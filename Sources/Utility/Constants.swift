import Foundation

/// Shortcut to access the default `FileManager` within this project.
public let fileManager = FileManager.default

/// Shortcut to access the `Logger` within this project.
public var log = Logger(outputType: .console)

/// Constants to reference across the project.
public enum Constants {
    /// The current tool version string. Conforms to SemVer 2.0.
    public static let currentVersion: String = "0.4.0"

    /// The name of this tool.
    public static let toolName: String = "AnyLint"

    /// The debug mode argument for command line pass-through.
    public static let debugArgument: String = "debug"

    /// The strict mode argument for command-line pass-through.
    public static let strictArgument: String = "strict"
}
