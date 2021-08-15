import Foundation
import ArgumentParser
import Configuration
import Core
import ShellOut

/// The `init` subcommand helping to get started with AnyLint by setting up a configuration file from a template.
struct InitCommand: ParsableCommand {
  static var configuration: CommandConfiguration = .init(
    commandName: "init",
    abstract: "Initializes a new AnyLint configuration file (at specified path & using the specified template)."
  )

  /// The template option to create the initial config file from.
  @Option(
    name: .shortAndLong,
    help: "The template to create the initial config file from. One of: \(Template.optionsDescription)."
  )
  var template: Template = .blank

  /// Path option to the new config file to initialize it at.
  @Option(
    name: .shortAndLong,
    help: "Path to the new config file to initialize it at. If a directory is specified, creates 'anylint.yml' in it."
  )
  var path: String = FileManager.default.currentDirectoryUrl.appendingPathComponent("anylint.yml").path

  mutating func run() throws {
    // if the specified path is a directory, assume the user wants the default file name
    if FileManager.default.fileExistsAndIsDirectory(atPath: path) {
      path = path.appendingPathComponent("anylint.yml")
    }

    guard !FileManager.default.fileExists(atPath: path) else {
      log.message("Configuration file already exists at path '\(path)'.", level: .error)
      log.exit(fail: true)
    }

    log.message("Making sure config file directory exists ...", level: .info)
    try shellOut(to: "mkdir", arguments: ["-p", path.parentDirectoryPath])

    log.message("Creating config file using template '\(template.rawValue)' ...", level: .info)
    FileManager.default.createFile(
      atPath: path,
      contents: template.fileContents,
      attributes: nil
    )

    log.message("Making config file executable ...", level: .info)
    try shellOut(to: "chmod", arguments: ["+x", path])

    log.message("Successfully created config file at \(path)", level: .success)

  }
}

extension Template: ExpressibleByArgument {}
