# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/).

<details>
<summary>Formatting Rules for Entries</summary>
Each entry should use the following format:

```markdown
- Summary of what was changed in a single line using past tense & followed by two whitespaces.  
  Issue: [#0](https://github.com/FlineDev/AnyLint/issues/0) | PR: [#0](https://github.com/FlineDev/AnyLint/pull/0) | Author: [Cihat Gündüz](https://github.com/Jeehut)
```

Note that at the end of the summary line, you need to add two whitespaces (`  `) for correct rendering on GitHub.

If needed, pluralize to `Tasks`, `PRs` or `Authors` and list multiple entries separated by `, `. Also, remove entries not needed in the second line.
</details>

## [Unreleased]
### Added
- None.
### Changed
- None.
### Deprecated
- None.
### Removed
- None.
### Fixed
- None.
### Security
- None.

## [0.9.0] - 2022-04-24
### Added
- Added new option `violationLocation` parameter for `checkFileContents` for specifying position of violation marker using `.init(range:bound:)`, where `range` can be one of `.fullMatch` or `.captureGroup(index:)` and bound one of `.lower` or `.upper`.

## [0.8.5] - 2022-04-24
### Fixed
- Fixed an issue where first violation can't be shown in Xcode due to 'swift-driver version: 1.45.2' printed on same line.

## [0.8.4] - 2022-04-01
### Fixed
- Fixed an issue with pointing to the wrong Swift-SH path on Apple Silicon Macs. Should also fix the path on Linux.  
  Author: [Cihat Gündüz](https://github.com/Jeehut) | Issue: [#46](https://github.com/FlineDev/AnyLint/issues/46)

## [0.8.3] - 2021-10-13
### Changed
- Bumped minimum required Swift tools version to 5.4.  
  Author: [Cihat Gündüz](https://github.com/Jeehut)
- Removed `Package.resolved` file to prevent pinning dependency versions.  
  Author: [Cihat Gündüz](https://github.com/Jeehut)

## [0.8.2] - 2020-06-09
### Changed
- Made internal extension methos public for usage in `customCheck`.  
  PR: [#35](https://github.com/FlineDev/AnyLint/pull/35) | Author: [Cihat Gündüz](https://github.com/Jeehut)
- Print diff out to console for multiline autocorrections that were applied.  
  Issue: [#27](https://github.com/FlineDev/AnyLint/issues/27) | PR: [#35](https://github.com/FlineDev/AnyLint/pull/35) | Author: [Cihat Gündüz](https://github.com/Jeehut)

## [0.8.1] - 2020-06-08
### Changed
- Made internal methods in types `FilesSearch` and `Violation` public for usage in `customCheck`.  
  PR: [#34](https://github.com/FlineDev/AnyLint/pull/34) | Author: [Cihat Gündüz](https://github.com/Jeehut)

## [0.8.0] - 2020-05-18
### Added
- Added new `repeatIfAutoCorrected` option to `checkFileContents` method to repeat the check if last run did any auto-corrections.  
  Issue: [#29](https://github.com/FlineDev/AnyLint/issues/29) | PR: [#31](https://github.com/FlineDev/AnyLint/pull/31) | Author: [Cihat Gündüz](https://github.com/Jeehut)
- Added new Regex Cheat Sheet section to README including a tip on how to workaround the pointer issue.  
  Issue: [#3](https://github.com/FlineDev/AnyLint/issues/3) | PR: [#32](https://github.com/FlineDev/AnyLint/pull/32) | Author: [Cihat Gündüz](https://github.com/Jeehut)

## [0.7.0] - 2020-05-18
### Added
- A new AnyLint custom check was added to ensure `AnyLint` fails when `LinuxMain.swift` isn't up-to-date, useful as a git pre-commit hook.  
  Author: [Cihat Gündüz](https://github.com/Jeehut) | PR: [#28](https://github.com/FlineDev/AnyLint/pull/28)
### Changed
- When a given `autoCorrectReplacement` on the `checkFileContents` method leads to no changes, the matched string of the given `regex` is considered to be already correct, thus no violation is reported anymore.  
  Issue: [#26](https://github.com/FlineDev/AnyLint/issues/26) | PR: [#28](https://github.com/FlineDev/AnyLint/pull/28) | Author: [Cihat Gündüz](https://github.com/Jeehut)
- A CI pipeline using GitHub Actions was setup, which is much faster as it runs multiple tasks in parallel than Bitrise.  
  Author: [Cihat Gündüz](https://github.com/Jeehut)

## [0.6.3] - 2020-05-07
### Added
- Summary output states how many files have been checked to make it easier to find include/exclude regexes.  
  Author: [Cihat Gündüz](https://github.com/Jeehut)
- Made `Violation` public for usage in `customCheck` methods.  
  Author: [Cihat Gündüz](https://github.com/Jeehut)
### Changed
- Removed version specifier from `lint.swift` file to get always latest `AnyLint` library.  
  Author: [Cihat Gündüz](https://github.com/Jeehut)

## [0.6.2] - 2020-04-30
### Fixed
- Attempt to fix an issue that lead to failed builds with an error on Linux CI servers.  
  Issue: [#22](https://github.com/FlineDev/AnyLint/issues/22) | Author: [Cihat Gündüz](https://github.com/Jeehut)

## [0.6.1] - 2020-04-25
### Changed
- Hugely improved performance of subsequent file searches with the same combination of `includeFilters` and `excludeFilters`. For example, if 30 checks were sharing the same filters, each file search is now ~8x faster.  
  Issue: [#20](https://github.com/FlineDev/AnyLint/issues/20) | PR: [#21](https://github.com/FlineDev/AnyLint/pull/21) | Author: [Cihat Gündüz](https://github.com/Jeehut)

## [0.6.0] - 2020-04-23
### Added
- Added a way to specify Regex options for literal initialization via `/i`, `/m` (String) or `#"\"#: "im"` (Dictionary).  
  PR: [#18](https://github.com/FlineDev/AnyLint/pull/18) | Author: [Cihat Gündüz](https://github.com/Jeehut)

## [0.5.0] - 2020-04-22
### Added
- New `-s` / `--strict` option to fail on warnings as well (by default fails only on errors).  
  PR: [#15](https://github.com/FlineDev/AnyLint/pull/15) | Author: [Cihat Gündüz](https://github.com/Jeehut)
- New `-l` / `--validate` option to only runs validations for `matchingExamples`, `nonMatchingExamples` and `autoCorrectExamples`.  
  PR: [#17](https://github.com/FlineDev/AnyLint/pull/17) | Author: [Cihat Gündüz](https://github.com/Jeehut)

## [0.4.0] - 2020-04-20
### Added
- New `-d` / `--debug` option to log more info about what AnyLint is doing. Required to add a checks completion block in `logSummaryAndExit` and moved it up in the blank template.  
  PR: [#13](https://github.com/FlineDev/AnyLint/pull/13) | Author: [Cihat Gündüz](https://github.com/Jeehut)

## [0.3.0] - 2020-04-16
### Added
- Made `AutoCorrection` expressible by Dictionary literals and updated the `README.md` accordingly.  
  Issue: [#5](https://github.com/FlineDev/AnyLint/issues/5) | PR: [#11](https://github.com/FlineDev/AnyLint/pull/11) | Author: [Cihat Gündüz](https://github.com/Jeehut)
- Added option to skip checks within file contents by specifying `AnyLint.skipHere: <CheckInfo.ID>` or `AnyLint.skipInFile: <All or CheckInfo.ID>`. Checkout the [Skip file content checks](https://github.com/FlineDev/AnyLint#skip-file-content-checks) README section for more info.  
  Issue: [#9](https://github.com/FlineDev/AnyLint/issues/9) | PR: [#12](https://github.com/FlineDev/AnyLint/pull/12) | Author: [Cihat Gündüz](https://github.com/Jeehut)

## [0.2.0] - 2020-04-10
### Added
- Added new `-x` / `--xcode` option to print out warnings & errors in an Xcode-compatible manner to improve user experience when used with an Xcode build script. Requires `arguments: CommandLine.arguments` as parameters to `logSummary` in config file.  
  Issue: [#4](https://github.com/FlineDev/AnyLint/issues/4) | PR: [#8](https://github.com/FlineDev/AnyLint/pull/8) | Author: [Cihat Gündüz](https://github.com/Jeehut)

## [0.1.1] - 2020-03-23
### Added
- Added two simple lint check examples in first code sample in README. (Thanks for the pointer, [Dave Verwer](https://github.com/daveverwer)!)  
  Author: [Cihat Gündüz](https://github.com/Jeehut)
### Changed
- Changed `CheckInfo` id casing convention from snake_case to UpperCamelCase in `blank` template.  
  Author: [Cihat Gündüz](https://github.com/Jeehut)

## [0.1.0] - 2020-03-22
Initial public release.
