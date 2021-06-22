// swift-tools-version:5.1
import PackageDescription

let package = Package(
  name: "AnyLint",
  products: [
    .library(name: "AnyLint", targets: ["AnyLint", "Utility"]),
    .executable(name: "anylint", targets: ["AnyLintCLI"]),
  ],
  dependencies: [
    // Delightful console output for Swift developers.
    .package(url: "https://github.com/onevcat/Rainbow.git", from: "3.1.5"),

    // A powerful framework for developing CLIs in Swift
    .package(url: "https://github.com/jakeheis/SwiftCLI.git", from: "6.0.1"),

    // A Sweet and Swifty YAML parser.
    .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.6"),
  ],
  targets: [
    .target(
      name: "AnyLint",
      dependencies: ["Utility"]
    ),
    .testTarget(
      name: "AnyLintTests",
      dependencies: ["AnyLint"]
    ),
    .target(
      name: "AnyLintCLI",
      dependencies: ["AnyLint", "Rainbow", "SwiftCLI", "Utility", "Yams"]
    ),
    .testTarget(
      name: "AnyLintCLITests",
      dependencies: ["AnyLintCLI"]
    ),
    .target(
      name: "Utility",
      dependencies: ["Rainbow"]
    ),
    .testTarget(
      name: "UtilityTests",
      dependencies: ["Utility"]
    )
  ]
)
