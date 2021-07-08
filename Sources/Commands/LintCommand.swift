import Foundation
import ArgumentParser
import Checkers
import Configuration
import Core
import Reporting
import Yams

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
  var paths: [String] = [FileManager.default.currentDirectoryUrl.path]

  @Option(
    name: .shortAndLong,
    help: .init("Path to the config file to execute.", valueName: "path")
  )
  var config: String = FileManager.default.currentDirectoryUrl.appendingPathComponent("anylint.yml").path

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
    log = Logger(outputFormat: outputFormat)

    guard FileManager.default.fileExists(atPath: config) else {
      log.message(
        "No configuration file found at \(config) – consider running `anylint --init` with a template.",
        level: .error
      )
      log.exit(fail: true)
      return  // only reachable in unit tests
    }

    let configFileUrl = URL(fileURLWithPath: config)
    let configFileData = try Data(contentsOf: configFileUrl)
    let lintConfig: LintConfiguration = try YAMLDecoder().decode(from: configFileData)

    do {
      log.message("Start linting using config file at \(config) ...", level: .info)

      try checksToPerform()

      Statistics.shared.logCheckSummary()

      if Statistics.shared.violations(severity: .error, excludeAutocorrected: outputFormat == .xcode).isFilled {
        log.exit(fail: true)
      }
      else if
        failLevel == .warning,
        Statistics.shared.violations(severity: .warning, excludeAutocorrected: outputFormat == .xcode).isFilled
      {
        log.exit(fail: true)
      }
      else {
        log.exit(status: .success)
      }









      try Lint.logSummaryAndExit(arguments: arguments) {
        for checkFileContent in lintConfig.checkFileContents {
          try Lint.checkFileContents(
            checkInfo: .init(id: checkFileContent.hint, hint: checkFileContent.hint),
            regex: .init(checkFileContent.regex),
            matchingExamples: checkFileContent.matchingExamples ?? [],
            nonMatchingExamples: checkFileContent.nonMatchingExamples ?? [],
            includeFilters: checkFileContent.includeFilters ?? [Regex(".*")],
            excludeFilters: checkFileContent.excludeFilters ?? [],
            autoCorrectReplacement: checkFileContent.autoCorrectReplacement,
            autoCorrectExamples: checkFileContent.autoCorrectExamples ?? [],
            repeatIfAutoCorrected: checkFileContent.repeatIfAutoCorrected ?? false
          )
        }

        for checkFilePath in lintConfig.checkFilePaths {
          try Lint.checkFilePaths(
            checkInfo: .init(id: checkFilePath.id, hint: checkFilePath.hint),
            regex: .init(checkFilePath.regex),
            matchingExamples: checkFilePath.matchingExamples ?? [],
            nonMatchingExamples: checkFilePath.nonMatchingExamples ?? [],
            includeFilters: checkFilePath.includeFilters ?? [Regex(".*")],
            excludeFilters: checkFilePath.excludeFilters ?? [],
            autoCorrectReplacement: checkFilePath.autoCorrectReplacement,
            autoCorrectExamples: checkFilePath.autoCorrectExamples ?? [],
            violateIfNoMatchesFound: checkFilePath.violateIfNoMatchesFound ?? false
          )
        }
      }

      log.message("Linting successful using config file at \(config). Congrats! 🎉", level: .success)
    }
    catch is RunError {
      if log.outputType != .xcode {
        log.message("Linting failed using config file at \(config).", level: .error)
      }

      throw LintError.configFileFailed
    }
  }
}

extension Severity: ExpressibleByArgument {}
extension OutputFormat: ExpressibleByArgument {}
