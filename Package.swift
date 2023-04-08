// swift-tools-version:5.4
import PackageDescription

let package = Package(
   name: "AnyLint",
   platforms: [.macOS(.v10_12)],
   products: [
      .library(name: "AnyLint", targets: ["AnyLint"]),
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
      .executableTarget(
         name: "AnyLintCLI",
         dependencies: ["Rainbow", "SwiftCLI", "Utility"]
      ),
      .testTarget(
         name: "AnyLintCLITests",
         dependencies: ["AnyLintCLI"]
      ),
      .testTarget(
         name: "UtilityTests",
         dependencies: ["Utility"]
      ),
      .target(
         name: "Utility",
         dependencies: ["Rainbow"]
      ),
   ]
)
