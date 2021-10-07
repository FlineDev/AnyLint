// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "AnyLint",
    products: [
        .library(name: "AnyLint", targets: ["AnyLint", "Utility"]),
        .executable(name: "anylint", targets: ["AnyLintCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Rainbow.git", from: "3.1.5"),
        .package(url: "https://github.com/jakeheis/SwiftCLI.git", from: "6.0.1"),
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
            dependencies: ["Rainbow", "SwiftCLI", "Utility"]
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
