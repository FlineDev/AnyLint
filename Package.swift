// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "AnyLint",
    platforms: [.macOS(.v10_12)],
    products: [
        .library(name: "AnyLint", targets: ["AnyLint", "Utility"]),
        .executable(name: "anylint", targets: ["AnyLintCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Rainbow.git", from: "3.1.5"),
        .package(url: "https://github.com/jakeheis/SwiftCLI.git", from: "6.0.1"),
    ],
    targets: [
        .executableTarget(
            name: "AnyLintCLI",
            dependencies: ["Rainbow", "SwiftCLI", "Utility"]
        ),
        .target(
            name: "AnyLint",
            dependencies: ["Utility"]
        ),
        .target(
            name: "Utility",
            dependencies: ["Rainbow"]
        ),
        .testTarget(
            name: "AnyLintTests",
            dependencies: ["AnyLint"]
        ),
        .testTarget(
            name: "AnyLintCLITests",
            dependencies: ["AnyLintCLI"]
        ),
        .testTarget(
            name: "UtilityTests",
            dependencies: ["Utility"]
        )
    ]
)

#if swift(>=5.6)
  // Add the documentation compiler plugin if possible
  package.dependencies.append(
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
  )
#endif
