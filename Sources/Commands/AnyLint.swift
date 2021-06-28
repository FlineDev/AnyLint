import ArgumentParser
import Foundation

@main
struct AnyLint: ParsableCommand {
  static var configuration: CommandConfiguration = .init(
    commandName: "anylint",
    abstract: "Lint anything by combining the power of scripts & regular expressions.",
    discussion: """
      Configure regex or script based rules in AnyLint expected YAML configuration format.

      AnyLint supports `FileContents` and `FilePaths` checks based on regexes with autocorrection & test support.
      Additionally, you can use `CustomScripts` to specify your own commands or scripts, e.g. other linters.
      """,
    version: "1.0.0",
    subcommands: [LintCommand.self, InitCommand.self],
    defaultSubcommand: LintCommand.self
  )
}
