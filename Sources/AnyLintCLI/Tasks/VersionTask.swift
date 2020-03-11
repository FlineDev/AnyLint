import Foundation

struct VersionTask { /* for extension purposes only */ }

extension VersionTask: Task {
    func perform() {
        log.message(Constants.currentVersion, level: .info)
    }
}
