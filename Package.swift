// swift-tools-version:5.3
import PackageDescription

let package = Package(
  name: "AnyLint",
  platforms: [.macOS(.v10_15)],
  products: [
    .executable(name: "anylint", targets: ["Commands"]),
  ],
  dependencies: [
    // Better Codable through Property Wrappers
    .package(url: "https://github.com/marksands/BetterCodable.git", from: "0.4.0"),

    // Delightful console output for Swift developers.
    .package(url: "https://github.com/onevcat/Rainbow.git", from: "4.0.0"),

    // Straightforward, type-safe argument parsing for Swift
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "0.4.3"),

    // Commonly used data structures for Swift`
    .package(url: "https://github.com/apple/swift-collections.git", from: "0.0.3"),

    // A collection of tools for debugging, diffing, and testing your application's data structures.
    .package(url: "https://github.com/pointfreeco/swift-custom-dump.git", from: "0.1.2"),

    // Easily run shell commands from a Swift script or command line tool
    .package(url: "https://github.com/JohnSundell/ShellOut.git", from: "2.3.0"),

    // A Sweet and Swifty YAML parser.
    .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.6"),
  ],
  targets: [
    .target(
      name: "Core",
      dependencies: [
        .product(name: "Rainbow", package: "Rainbow"),
      ]
    ),
    .target(
      name: "Checkers",
      dependencies: [
        "Core",
        "Reporting",
        .product(name: "ShellOut", package: "ShellOut"),
      ]
    ),
    .target(
      name: "Configuration",
      dependencies: [
        .product(name: "BetterCodable", package: "BetterCodable"),
        "Core",
        .product(name: "Yams", package: "Yams"),
      ],
      resources: [
        .copy("Templates"),
      ]
    ),
    .target(
      name: "Reporting",
      dependencies: [
        "Core",
        .product(name: "OrderedCollections", package: "swift-collections"),
      ]
    ),
    .target(
      name: "Commands",
      dependencies: [
        "Checkers",
        "Configuration",
        "Core",
        "Reporting",
        .product(name: "ShellOut", package: "ShellOut"),
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]
    ),

    // test targets
    .target(
      name: "TestSupport",
      dependencies: [
        "Core",
        .product(name: "CustomDump", package: "swift-custom-dump"),
        .product(name: "Rainbow", package: "Rainbow"),
      ]
    ),
    .testTarget(name: "CoreTests", dependencies: ["Core", "TestSupport"]),
    .testTarget(name: "CheckersTests", dependencies: ["Checkers", "TestSupport"]),
    .testTarget(name: "ConfigurationTests", dependencies: ["Configuration"]),
    .testTarget(name: "ReportingTests", dependencies: ["Reporting", "TestSupport"]),
    .testTarget(name: "CommandsTests", dependencies: ["Commands"]),
  ]
)
