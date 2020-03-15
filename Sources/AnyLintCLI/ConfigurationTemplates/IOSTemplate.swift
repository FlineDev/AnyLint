import Foundation
import Utility

enum IOSTemplate: ConfigurationTemplate {
    static func fileContents() -> String {
        """
        #!\(CLIConstants.swiftShPath)
        import AnyLint // @Flinesoft ~> \(Constants.currentVersion)

        // TODO: [cg_2020-03-11] not yet implemented

        Lint.logSummaryAndExit()

        """
    }
}
