import Foundation
import Utility

struct VersionTask { /* for extension purposes only */ }

extension VersionTask: TaskHandler {
   func perform() throws {
      log.message(Constants.currentVersion, level: .info)
   }
}
