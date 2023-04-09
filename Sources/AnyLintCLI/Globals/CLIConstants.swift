import Foundation

enum CLIConstants {
   static let commandName: String = "anylint"
   static let defaultConfigFileName: String = "lint.swift"
   static let initTemplateCases: String = InitTask.Template.allCases.map { $0.rawValue }.joined(separator: ", ")
   static var swiftShPath: String {
      switch self.getPlatform() {
      case .intel:
         return "/usr/local/bin/swift-sh"

      case .appleSilicon:
         return "/opt/homebrew/bin/swift-sh"

      case .linux:
         return "/home/linuxbrew/.linuxbrew/bin/swift-sh"
      }
   }
}

extension CLIConstants {
   fileprivate enum Platform {
      case intel
      case appleSilicon
      case linux
   }

   fileprivate static func getPlatform() -> Platform {
      #if os(Linux)
         return .linux
      #else
      // Source: https://stackoverflow.com/a/69624732
         var systemInfo = utsname()
         let exitCode = uname(&systemInfo)

         let fallbackPlatform: Platform = .appleSilicon
         guard exitCode == EXIT_SUCCESS else { return fallbackPlatform }

         let cpuArchitecture = String(cString: &systemInfo.machine.0, encoding: .utf8)
         switch cpuArchitecture {
         case "x86_64":
            return .intel

         case "arm64":
            return .appleSilicon

         default:
            return fallbackPlatform
         }
      #endif
   }
}
