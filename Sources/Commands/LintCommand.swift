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

  /// The path(s) option to run the checks from.
  @Option(
    name: .shortAndLong,
    parsing: .upToNextOption,
    help: .init("The path(s) to run the checks from.", valueName: "path")
  )
  var paths: [String] = [FileManager.default.currentDirectoryUrl.path]

  /// Path option to the config file to execute.
  @Option(
    name: .shortAndLong,
    help: .init("Path to the config file to execute.", valueName: "path")
  )
  var config: String = FileManager.default.currentDirectoryUrl.appendingPathComponent("anylint.yml").path

  /// The minimum severity level option to fail on if any checks produce violations.
  @Option(
    name: .shortAndLong,
    help: .init(
      "The minimum severity level to fail on if any checks produce violations. One of: \(Severity.optionsDescription).",
      valueName: "severity"
    )
  )
  var failLevel: Severity = .error

  /// The expected format option of the output.
  @Option(
    name: .shortAndLong,
    help: .init(
      "The expected format of the output. One of: \(OutputFormat.optionsDescription).",
      valueName: "format"
    )
  )
  var outputFormat: OutputFormat = .commandLine

  mutating func run() throws {
    if outputFormat == .xcode {
      log = Logger.xcode
    }

    guard FileManager.default.fileExists(atPath: config) else {
      log.message(
        "No configuration file found at \(config) – consider running `anylint init` with a template.",
        level: .error
      )
      log.exit(fail: true)
    }

    let configFileUrl = URL(fileURLWithPath: config)
    let configFileData = try Data(contentsOf: configFileUrl)
    let lintConfig: LintConfiguration = try YAMLDecoder().decode(from: configFileData)

    log.message("Start linting using config file at \(config) ...", level: .info)
    var lintResults: LintResults = [.info: [:], .warning: [:], .error: [:]]

    // run `FileContents` checks
    for fileContentsConfig in lintConfig.fileContents {
      let violations = try Lint.checkFileContents(
        check: fileContentsConfig.check,
        regex: fileContentsConfig.regex,
        matchingExamples: fileContentsConfig.matchingExamples,
        nonMatchingExamples: fileContentsConfig.nonMatchingExamples,
        includeFilters: fileContentsConfig.includeFilters,
        excludeFilters: fileContentsConfig.excludeFilters,
        autoCorrectReplacement: fileContentsConfig.autoCorrectReplacement,
        autoCorrectExamples: fileContentsConfig.autoCorrectExamples,
        repeatIfAutoCorrected: fileContentsConfig.repeatIfAutoCorrected
      )

      lintResults.appendViolations(violations, forCheck: fileContentsConfig.check)
    }

    // run `FilePaths` checks
    for filePathsConfig in lintConfig.filePaths {
      let violations = try Lint.checkFilePaths(
        check: filePathsConfig.check,
        regex: filePathsConfig.regex,
        matchingExamples: filePathsConfig.matchingExamples,
        nonMatchingExamples: filePathsConfig.nonMatchingExamples,
        includeFilters: filePathsConfig.includeFilters,
        excludeFilters: filePathsConfig.excludeFilters,
        autoCorrectReplacement: filePathsConfig.autoCorrectReplacement,
        autoCorrectExamples: filePathsConfig.autoCorrectExamples,
        violateIfNoMatchesFound: filePathsConfig.violateIfNoMatchesFound
      )

      lintResults.appendViolations(violations, forCheck: filePathsConfig.check)
    }

    // run `CustomScripts` checks
    for customScriptConfig in lintConfig.customScripts {
      let customScriptLintResults = try Lint.runCustomScript(
        check: customScriptConfig.check,
        command: customScriptConfig.command
      )

      lintResults.mergeResults(customScriptLintResults)
    }

    // report violations & exit with right status code
    lintResults.report(outputFormat: outputFormat)

    if lintResults.violations(severity: .error, excludeAutocorrected: outputFormat == .xcode).isFilled {
      log.exit(fail: true)
    }
    else if failLevel == .warning,
      lintResults.violations(severity: .warning, excludeAutocorrected: outputFormat == .xcode).isFilled
    {
      log.exit(fail: true)
    }
    else {
      log.message("Linting successful using config file at \(config). Congrats! 🎉", level: .success)
      log.exit(fail: false)
    }
  }
}

extension Severity: ExpressibleByArgument {}
extension OutputFormat: ExpressibleByArgument {}

extension CheckConfiguration {
  var check: Check {
    .init(id: id, hint: hint, severity: severity)
  }
}
