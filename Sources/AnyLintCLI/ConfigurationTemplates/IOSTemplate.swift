import Foundation

// swiftlint:disable trailing_whitespace

enum IOSTemplate: ConfigurationTemplate {
    static let fileContents: String = """
        #!/usr/local/bin/swift-sh
        import AnyLint // @Flinesoft ~> \(Constants.currentVersion)

        // TODO: [cg_2020-03-11] not yet implemented
        
        """
}
