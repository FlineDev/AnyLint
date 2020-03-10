import Foundation

struct InitTask {
    enum Template: String, CaseIterable {
        case blank
        case ios
        case android
    }

    let path: String
    let template: Template
}

extension InitTask: Task {
    func perform() {
        // TODO: [cg_2020-03-10] not yet implemented
    }
}
