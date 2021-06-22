import AnyLint
import Foundation
import SwiftCLI
import Utility
import Yams

struct LintTask {
  let configFilePath: String
  let logDebugLevel: Bool
  let failOnWarnings: Bool
  let validateOnly: Bool
}

extension LintTask: TaskHandler {
  enum LintError: Error {
    case configFileFailed
  }

  /// - Throws: `LintError.configFileFailed` if running a configuration file fails
  func perform() throws {
    try ValidateOrFail.configFileExists(at: configFilePath)

    let configFileUrl = URL(fileURLWithPath: configFilePath)
    let configFileData = try Data(contentsOf: configFileUrl)
    let lintConfig: LintConfiguration = try YAMLDecoder().decode(from: configFileData)

    do {
      log.message("Start linting using config file at \(configFilePath) ...", level: .info)

      var arguments: [String] = [log.outputType.rawValue]

      if logDebugLevel {
        arguments.append(Constants.debugArgument)
      }

      if failOnWarnings {
        arguments.append(Constants.strictArgument)
      }

      if validateOnly {
        arguments.append(Constants.validateArgument)
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

      log.message("Linting successful using config file at \(configFilePath). Congrats! 🎉", level: .success)
    }
    catch is RunError {
      if log.outputType != .xcode {
        log.message("Linting failed using config file at \(configFilePath).", level: .error)
      }

      throw LintError.configFileFailed
    }
  }
}
