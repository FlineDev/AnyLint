// swift-tools-version:5.1
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
            dependencies: ["SwiftCLI", "Utility"]
        ),
        .testTarget(
            name: "AnyLintTests",
            dependencies: ["AnyLint", "Rainbow", "SwiftCLI"]
        ),
        .target(
            name: "AnyLintCLI",
            dependencies: ["Rainbow", "SwiftCLI", "Utility"]
        ),
        .target(
            name: "Utility",
            dependencies: ["Rainbow", "SwiftCLI"]
        ),
        .testTarget(
            name: "UtilityTests",
            dependencies: ["Utility"]
        )
    ]
)
