import ArgumentParser
import Configuration
import Core
import Foundation

struct InitCommand: ParsableCommand {
  static var configuration: CommandConfiguration = .init(
    commandName: "init",
    abstract: "Initializes a new AnyLint configuration file (at specified path & using the specified template)."
  )

  @Option(
    name: .shortAndLong,
    help: "The template to create the initial config file from. One of: \(Template.optionsDescription)."
  )
  var template: Template = .blank

  @Option(
    name: .shortAndLong,
    help: "Path to the new config file to initialize it at."
  )
  var path: String = URL(fileURLWithPath: ".").appendingPathComponent("anylint.yml").path

  mutating func run() throws {
    // TODO: [cg_2021-06-28] not yet implemented
  }
}

extension Template: ExpressibleByArgument {}
