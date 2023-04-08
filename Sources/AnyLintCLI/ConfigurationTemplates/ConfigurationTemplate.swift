import Foundation
import Utility

protocol ConfigurationTemplate {
   static func fileContents() -> String
}

extension ConfigurationTemplate {
   static var commonPrefix: String {
        """
        #!\(CLIConstants.swiftShPath)
        import AnyLint // @FlineDev
        
        try Lint.logSummaryAndExit(arguments: CommandLine.arguments) {
        
        """
   }
   
   static var commonSuffix: String {
        """
        
        }
        
        """
   }
}
