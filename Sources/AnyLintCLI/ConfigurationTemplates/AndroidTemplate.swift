import Foundation
import Utility

// swiftlint:disable trailing_whitespace

enum AndroidTemplate: ConfigurationTemplate {
    static func fileContents() -> String {
        """
        #!\(CLIConstants.swiftShPath)
        import AnyLint // @Flinesoft ~> \(Constants.currentVersion)

        // TODO: [cg_2020-03-11] not yet implemented

        Lint.logSummaryAndExit()
        
        """
    }
}
