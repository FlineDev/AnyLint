import Foundation

struct VersionTask { /* for extension purposes only */ }

extension VersionTask: Task {
    func perform() {
        // TODO: [cg_2020-03-10] replace print with more semantically weighted output that also makes CLI testable
        print(Constants.currentVersion)
    }
}
