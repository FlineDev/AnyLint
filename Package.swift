// swift-tools-version:5.5
import PackageDescription

let package = Package(
  name: "AnyLint",
  products: [
    .executable(name: "anylint", targets: ["Commands"]),
  ],
  dependencies: [
    // Delightful console output for Swift developers.
    .package(url: "https://github.com/onevcat/Rainbow.git", from: "4.0.0"),

    // Straightforward, type-safe argument parsing for Swift
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "0.4.3"),

    // A Sweet and Swifty YAML parser.
    .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.6"),
  ],
  targets: [
    .target(
      name: "Core",
      dependencies: [
        .product(name: "Rainbow", package: "Rainbow")
      ]
    ),
    .target(name: "Checkers", dependencies: ["Core"]),
    .target(
      name: "Configuration",
      dependencies: [
        "Core",
        .product(name: "Yams", package: "Yams"),
      ]
    ),
    .target(name: "Reporting", dependencies: ["Core"]),
    .executableTarget(
      name: "Commands",
      dependencies: [
        "Configuration",
        "Core",
        "Reporting",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]
    ),

    // test targets
    .testTarget(name: "CoreTests", dependencies: ["Core"]),
    .testTarget(name: "CheckersTests", dependencies: ["Checkers"]),
    .testTarget(name: "ConfigurationTests", dependencies: ["Configuration"]),
    .testTarget(name: "ReportingTests", dependencies: ["Reporting"]),
    .testTarget(name: "CommandsTests", dependencies: ["Commands"]),
  ]
)
