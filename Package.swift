// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "AnyLint",
    products: [
        .library(name: "AnyLint", targets: ["AnyLint"]),
        .executable(name: "anylint", targets: ["AnyLintCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Flinesoft/HandySwift.git", from: "3.1.0"),
        .package(url: "https://github.com/jakeheis/SwiftCLI.git", from: "6.0.1"),
    ],
    targets: [
        .target(
            name: "AnyLint",
            dependencies: ["HandySwift"]
        ),
        .testTarget(
            name: "AnyLintTests",
            dependencies: ["AnyLint"]
        ),
        .target(
            name: "AnyLintCLI",
            dependencies: ["HandySwift", "SwiftCLI"]
        ),
        .testTarget(
            name: "AnyLintCLITests",
            dependencies: ["AnyLintCLI"]
        ),
    ]
)
