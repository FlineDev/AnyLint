# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/).

<details>
<summary>Formatting Rules for Entries</summary>
Each entry should use the following format:

```markdown
- Summary of what was changed in a single line using past tense & followed by two whitespaces.  
  Issue: [#0](https://github.com/Flinesoft/AnyLint/issues/0) | PR: [#0](https://github.com/Flinesoft/AnyLint/pull/0) | Author: [Cihat Gündüz](https://github.com/Jeehut)
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

## [0.3.0] - 2020-04-16
### Added
- Made `AutoCorrection` expressible by Dictionary literals and updated the `README.md` accordingly.  
  Issue: [#5](https://github.com/Flinesoft/AnyLint/issues/5) | PR: [#11](https://github.com/Flinesoft/AnyLint/pull/11) | Author: [Cihat Gündüz](https://github.com/Jeehut)
- Added option to skip checks within file contents by specifying `AnyLint.skipHere: <CheckInfo.ID>` or `AnyLint.skipInFile: <All or CheckInfo.ID>`. Checkout the [Skip file content checks](https://github.com/Flinesoft/AnyLint#skip-file-content-checks) README section for more info.  
  Issue: [#9](https://github.com/Flinesoft/AnyLint/issues/9) | PR: [#12](https://github.com/Flinesoft/AnyLint/pull/12) | Author: [Cihat Gündüz](https://github.com/Jeehut)

## [0.2.0] - 2020-04-10
### Added
- Added new `-x` / `--xcode` option to print out warnings & errors in an Xcode-compatible manner to improve user experience when used with an Xcode build script. Requires `arguments: CommandLine.arguments` as parameters to `logSummary` in config file.  
  Issue: [#4](https://github.com/Flinesoft/AnyLint/issues/4) | PR: [#8](https://github.com/Flinesoft/AnyLint/pull/8) | Author: [Cihat Gündüz](https://github.com/Jeehut)

## [0.1.1] - 2020-03-23
### Added
- Added two simple lint check examples in first code sample in README. (Thanks for the pointer, [Dave Verwer](https://github.com/daveverwer)!)  
  Author: [Cihat Gündüz](https://github.com/Jeehut)
### Changed
- Changed `CheckInfo` id casing convention from snake_case to UpperCamelCase in `blank` template.  
  Author: [Cihat Gündüz](https://github.com/Jeehut)

## [0.1.0] - 2020-03-22
Initial public release.
