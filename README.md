<p align="center">
    <img src="https://raw.githubusercontent.com/Flinesoft/AnyLint/main/Logo.png"
      width=562 height=115>
</p>

<p align="center">
    <a href="https://app.bitrise.io/app/b2708c16ab236ff8">
        <img src="https://app.bitrise.io/app/b2708c16ab236ff8/status.svg?token=PuELIpLj_V11GkcIztEgGQ&branch=main"
            alt="Build Status">
    </a>
    <a href="https://www.codacy.com/gh/Flinesoft/AnyLint">
        <img src="https://api.codacy.com/project/badge/Grade/c881ee12938145d3bfd398eff1571228"
             alt="Code Quality"/>
    </a>
    <a href="https://www.codacy.com/gh/Flinesoft/AnyLint">
        <img src="https://api.codacy.com/project/badge/Coverage/c881ee12938145d3bfd398eff1571228"
             alt="Coverage"/>
    </a>
    <a href="https://github.com/Flinesoft/AnyLint/releases">
        <img src="https://img.shields.io/badge/Version-0.1.1-blue.svg"
             alt="Version: 0.1.1">
    </a>
    <a href="https://github.com/Flinesoft/AnyLint/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-MIT-lightgrey.svg"
             alt="License: MIT">
    </a>
    <br />
    <a href="https://paypal.me/Dschee/5EUR">
        <img src="https://img.shields.io/badge/PayPal-Donate-orange.svg"
             alt="PayPal: Donate">
    </a>
    <a href="https://github.com/sponsors/Jeehut">
        <img src="https://img.shields.io/badge/GitHub-Become a sponsor-orange.svg"
             alt="GitHub: Become a sponsor">
    </a>
    <a href="https://patreon.com/Jeehut">
        <img src="https://img.shields.io/badge/Patreon-Become a patron-orange.svg"
             alt="Patreon: Become a patron">
    </a>
</p>

<p align="center">
  <a href="#installation">Installation</a>
  • <a href="#getting-started">Getting Started</a>
  • <a href="#configuration">Configuration</a>
  • <a href="#donation">Donation</a>
  • <a href="https://github.com/Flinesoft/AnyLint/issues">Issues</a>
  • <a href="#contributing">Contributing</a>
  • <a href="#license">License</a>
</p>

# AnyLint

Lint any project in any language using Swift and regular expressions. With built-in support for matching and non-matching examples validation & autocorrect replacement. Replaces SwiftLint custom rules & works for other languages as well! 🎉

## Installation

### Via [Homebrew](https://brew.sh):

To **install** AnyLint the first time, run these commands:

```bash
brew tap Flinesoft/AnyLint https://github.com/Flinesoft/AnyLint.git
brew install anylint
```

To **update** it to the latest version, run this instead:

```bash
brew upgrade anylint
```

### Via [Mint](https://github.com/yonaskolb/Mint):

To **install** AnyLint or **update** to the latest version, run this command:

```bash
mint install Flinesoft/AnyLint
```

## Getting Started

To initialize AnyLint in a project, run:

```bash
anylint --init blank
```

This will create the Swift script file `lint.swift` with something like the following contents:

```swift
#!/usr/local/bin/swift-sh
import AnyLint // @Flinesoft ~> 0.1.1

// MARK: - Variables
let readmeFile: Regex = #"README\.md"#

// MARK: - Checks
// MARK: Readme
try Lint.checkFilePaths(
    checkInfo: "Readme: Each project should have a README.md file explaining the project.",
    regex: readmeFile,
    matchingExamples: ["README.md"],
    nonMatchingExamples: ["README.markdown", "Readme.md", "ReadMe.md"],
    violateIfNoMatchesFound: true
)

// MARK: ReadmeTypoLicense
try Lint.checkFileContents(
    checkInfo: "ReadmeTypoLicense: Misspelled word 'license'.",
    regex: #"([\s#]L|l)isence([\s\.,:;])"#,
    matchingExamples: [" license:", "## Lisence\n"],
    nonMatchingExamples: [" license:", "## License\n"],
    includeFilters: [readmeFile],
    autoCorrectReplacement: "$1icense$2",
    autoCorrectExamples: [
        AutoCorrection(before: " license:", after: " license:"),
        AutoCorrection(before: "## Lisence\n", after: "## License\n"),
    ]
)

// MARK: - Log Summary & Exit
Lint.logSummaryAndExit()
```

The most important thing to note is that the **first two lines and the last line are required** for AnyLint to work properly.

Other than that, all the other code in between can be adjusted and that's actually where you configure your lint checks (a few examples are provided by default in the `blank` template). Note that the first two lines declare the file to be a Swift script using [swift-sh](https://github.com/mxcl/swift-sh). Thus, you can run any Swift code and even import Swift packages (see the [swift-sh docs](https://github.com/mxcl/swift-sh#usage)) if you need to. The last line makes sure that all violations found in the process of running the previous code are reported properly and exits the script with the proper exit code.

Having this configuration file, you can now run `anylint` to run your lint checks. By default, if any check fails, the entire command fails and reports the violation reason. To learn more about how to configure your own checks, see the [Configuration](#configuration) section below.

If you want to create and run multiple configuration files or if you want a different name or location for the default config file, you can pass the `--path` option, which can be used multiple times as well like this:

Initializes the configuration files at the given locations:
```bash
anylint --init blank --path Sources/lint.swift --path Tests/lint.swift
```

Runs the lint checks for both configuration files:
```bash
anylint --path Sources/lint.swift --path Tests/lint.swift
```

## Configuration

AnyLint provides three different kinds of lint checks:

1. `checkFileContents`: Matches the contents of a text file to a given regex.
2. `checkFilePaths`: Matches the file paths of the current directory to a given regex.
3. `customCheck`: Allows to write custom Swift code to do other kinds of checks.

Several examples of lint checks can be found in the [`lint.swift` file of this very project](https://github.com/Flinesoft/AnyLint/blob/main/lint.swift).

### Basic Types

Independent from the method used, there are a few types specified in the AnyLint package you should know of.

#### Regex

Many parameters in the above mentioned lint check methods are of `Regex` type. A `Regex` can be initialized in several ways:

1. Using a **String**:
  ```swift
  let regex = Regex(#"(foo|bar)[0-9]+"#) // => /(foo|bar)[0-9]+/`
  ```
2. Using a **String Literal**:
  ```swift
  let regex: Regex = #"(foo|bar)[0-9]+"#  // => /(foo|bar)[0-9]+/
  ```
3. Using a **Dictionary Literal**: (use for [named capture groups](https://www.regular-expressions.info/named.html))
  ```swift
  let regex: Regex = ["key": #"foo|bar"#, "num": "[0-9]+"]
  // => /(?<key>foo|bar)(?<num>[0-9]+)/
  ```

Note that we recommend using [raw strings](https://www.hackingwithswift.com/articles/162/how-to-use-raw-strings-in-swift) (`#"foo"#` instead of `"foo"`) for all regexes to get rid of double escaping backslashes (e.g. `\\s` becomes `\s`). This also allows for testing regexes in online regex editors like [rubular](https://rubular.com/) first and then copy & pasting from them without any additional escaping.

#### CheckInfo

A `CheckInfo` contains the basic information about a lint check. It consists of:

1. `id`: The identifier of your lint check. For example: `EmptyTodo`
2. `hint`: The hint explaining the cause of the violation or the steps to fix it.
3. `severity`: The severity of violations. One of `error`, `warning`, `info`. Default: `error`

While there is an initializer available, we recommend using a String Literal instead like so:

```swift
// accepted structure: <id>(@<severity>): <hint>
let checkInfo: CheckInfo = "ReadmePath: The README file should be named exactly `README.md`."
```

### Check File Contents

AnyLint has rich support for checking the contents of a file using a regex. The design follows the approach "make simple things simple and hard things possible". Thus, let's explain the `checkFileContents` method with a simple and a complex example.

In its simplest form, the method just requires a `checkInfo` and a `regex`:

```swift
// MARK: empty_todo
try Lint.checkFileContents(
    checkInfo: "EmptyTodo: TODO comments should not be empty.",
    regex: #"// TODO: *\n"#
)
```

But we *strongly recommend* to always provide also:

1. `matchingExamples`: Array of strings expected to match the given string for `regex` validation.
2. `nonMatchingExamples`: Array of strings not matching the given string for `regex` validation.
3. `includeFilters`: Array of `Regex` objects to include to the file paths to check.

The first two will be used on each run of AnyLint to check if the provided `regex` actually works as expected. If any of the `matchingExamples` doesn't match or if any of the `nonMatchingExamples` _does_ match, the entire AnyLint command will fail early. This a built-in validation step to help preventing a lot of issues and increasing your confidence on the lint checks.

The third one is recommended because it increases the performance of the linter. Only files at paths matching at least one of the provided regexes will be checked. If not provided, all files within the current directory will be read recursively for each check, which is inefficient.

Here's the *recommended minimum example*:

```swift
// MARK: - Variables
let swiftSourceFiles: Regex = #"Sources/.*\.swift"#
let swiftTestFiles: Regex = #"Tests/.*\.swift"#

// MARK: - Checks
// MARK: empty_todo
try Lint.checkFileContents(
    checkInfo: "EmptyTodo: TODO comments should not be empty.",
    regex: #"// TODO: *\n"#,
    matchingExamples: ["// TODO:\n"],
    nonMatchingExamples: ["// TODO: not yet implemented\n"],
    includeFilters: [swiftSourceFiles, swiftTestFiles]
)
```

There's 3 more parameters you can optionally set if needed:

1. `excludeFilters`: Array of `Regex` objects to exclude from the file paths to check.
2. `autoCorrectReplacement`: Replacement string which can reference any capture groups in the `regex`.
3. `autoCorrectExamples`: Example structs with `before` and `after` for autocorrection validation.

The `excludeFilters` can be used alternatively to the `includeFilters` or alongside them. If used alongside, exclusion will take precedence over inclusion.

If `autoCorrectReplacement` is provided, AnyLint will automatically replace matches of `regex` with the given replacement string. Capture groups are supported, both in numbered style (`([a-z]+)(\d+)` => `$1$2`) and named group style (`(?<alpha>[a-z])(?<num>\d+)` => `$alpha$num`). When provided, we strongly recommend to also provide `autoCorrectExamples` for validation. Like for `matchingExamples` / `nonMatchingExamples` the entire command will fail early if one of the examples doesn't correct from the `before` string to the expected `after` string.

> *Caution:* When using the `autoCorrectReplacement` parameter, be sure to double-check that your regex doesn't match too much content. Additionally, we strongly recommend to commit your changes regularly to have some backup.

Here's a *full example using all parameters* at once:

```swift
// MARK: - Variables
let swiftSourceFiles: Regex = #"Sources/.*\.swift"#
let swiftTestFiles: Regex = #"Tests/.*\.swift"#

// MARK: - Checks
// MARK: empty_method_body
try Lint.checkFileContents(
    checkInfo: "EmptyMethodBody: Don't use whitespaces for the body of empty methods.",
    regex: [
      "declaration": #"func [^\(\s]+\([^{]*\)"#,
      "spacing": #"\s*"#,
      "body": #"\{\s+\}"#
    ],
    matchingExamples: [
        "func foo2bar()  { }",
        "func foo2bar(x: Int, y: Int)  { }",
        "func foo2bar(\n    x: Int,\n    y: Int\n) {\n    \n}",
    ],
    nonMatchingExamples: [
      "func foo2bar() {}",
      "func foo2bar(x: Int, y: Int) {}"
    ],
    includeFilters: [swiftSourceFiles],
    excludeFilters: [swiftTestFiles],
    autoCorrectReplacement: "$declaration {}",
    autoCorrectExamples: [
        AutoCorrection(before: "func foo2bar()  { }", after: "func foo2bar() {}"),
        AutoCorrection(before: "func foo2bar(x: Int, y: Int)  { }", after: "func foo2bar(x: Int, y: Int) {}"),
        AutoCorrection(before: "func foo2bar()\n{\n    \n}", after: "func foo2bar() {}"),
    ]
)
```

### Check File Paths

The `checkFilePaths` method has all the same parameters like the `checkFileContents` method, so please read the above section to learn more about them. There's only one difference and one additional parameter:

1. `autoCorrectReplacement`: Here, this will safely move the file using the path replacement.
2. `violateIfNoMatchesFound`: Will report a violation if _no_ matches are found if `true`. Default: `false`

As this method is about file paths and not file contents, the `autoCorrectReplacement` actually also fixes the paths, which corresponds to moving files from the `before` state to the `after` state. Note that moving/renaming files here is done safely, which means that if a file already exists at the resulting path, the command will fail.

By default, `checkFilePaths` will fail if the given `regex` matches a file. If you want to check for the _existence_ of a file though, you can set `violateIfNoMatchesFound` to `true` instead, then the method will fail if it does _not_ matchn any file.

### Custom Checks

AnyLint allows you to do any kind of lint checks (thus its name) as it gives you the full power of the Swift programming language and it's packages ecosystem. The `customCheck` method needs to be used to profit from this flexibility. And it's actually the simplest of the three methods, consisting of only two parameters:

1. `checkInfo`: Provides some general information on the lint check.
2. `customClosure`: Your custom logic which produces an array of `Violation` objects.

Note that the `Violation` type just holds some additional information on the file, matched string, location in the file and applied autocorrection and that all these fields are optional. It is a simple struct used by the AnyLint reporter for more detailed output, no logic attached. The only required field is the `CheckInfo` object which caused the violation.

If you want to use regexes in your custom code, you can learn more about how you can match strings with a `Regex` object on [the HandySwift docs](https://github.com/Flinesoft/AnyLint/blob/main/Sources/Utility/Regex.swift) (the project, the class was taken from) or read the [code documentation comments](https://github.com/Flinesoft/AnyLint/blob/main/Sources/Utility/Regex.swift).

When using the `customCheck`, you might want to also include some Swift packages for [easier file handling](https://github.com/JohnSundell/Files) or [running shell commands](https://github.com/JohnSundell/ShellOut). You can do so by adding them at the top of the file like so:

> TODO: Improve the below code example with something more useful & realistic.

```swift
#!/usr/local/bin/swift-sh
import AnyLint // @Flinesoft ~> 0.1.1
import Files // @JohnSundell ~> 4.1.1
import ShellOut // @JohnSundell ~> 2.3.0

// MARK: echo
try Lint.customCheck(checkInfo: "Echo: Always say hello to the world.") {
    var violations: [Violation] = []

    // use ShellOut package
    let output = try shellOut(to: "echo", arguments: ["Hello world"])
    // ...

    // use Files package
    try Folder(path: "MyFolder").files.forEach { file in
        // ...
    }

    return violations
}

// MARK: - Log Summary & Exit
Lint.logSummaryAndExit()
```

## Donation

AnyLint was brought to you by [Cihat Gündüz](https://github.com/Jeehut) in his free time. If you want to thank me and support the development of this project, please **make a small donation on [PayPal](https://paypal.me/Dschee/5EUR)**. In case you also like my other [open source contributions](https://github.com/Flinesoft) and [articles](https://medium.com/@Jeehut), please consider motivating me by **becoming a sponsor on [GitHub](https://github.com/sponsors/Jeehut)** or a **patron on [Patreon](https://www.patreon.com/Jeehut)**.

Thank you very much for any donation, it really helps out a lot! 💯

## Contributing

Contributions are welcome. Feel free to open an issue on GitHub with your ideas or implement an idea yourself and post a pull request. If you want to contribute code, please try to follow the same syntax and semantic in your **commit messages** (see rationale [here](http://chris.beams.io/posts/git-commit/)). Also, please make sure to add an entry to the `CHANGELOG.md` file which explains your change.

## License

This library is released under the [MIT License](http://opensource.org/licenses/MIT). See LICENSE for details.
