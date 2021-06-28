import ArgumentParser
import Core
import Foundation
import Reporting

struct LintCommand: ParsableCommand {
  static var configuration: CommandConfiguration = .init(
    commandName: "lint",
    abstract: "Runs the configured checks & reports the results in the specified format."
  )

  @Option(
    name: .shortAndLong,
    parsing: .upToNextOption,
    help: .init("The path(s) to run the checks from.", valueName: "path")
  )
  var paths: [String] = [URL(fileURLWithPath: ".").path]

  @Option(
    name: .shortAndLong,
    help: .init("Path to the config file to execute.", valueName: "path")
  )
  var config: String = URL(fileURLWithPath: ".").appendingPathComponent("anylint.yml").path

  @Option(
    name: .shortAndLong,
    help: .init(
      "The minimum severity level to fail on if any checks produce violations. One of: \(Severity.optionsDescription).",
      valueName: "severity"
    )
  )
  var failLevel: Severity = .error

  @Option(
    name: .shortAndLong,
    help: .init(
      "The expected format of the output. One of: \(OutputFormat.optionsDescription).",
      valueName: "format"
    )
  )
  var outputFormat: OutputFormat = .commandLine

  @Flag(
    name: .shortAndLong,
    help: "Enables more verbose output for more details."
  )
  var verbose: Bool = false

  mutating func run() throws {
    // TODO: [cg_2021-06-28] not yet implemented
  }
}

extension Severity: ExpressibleByArgument {}
extension OutputFormat: ExpressibleByArgument {}
