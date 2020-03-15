import Foundation
import HandySwift

struct LastCommitMessageChecker {
    let checkInfo: CheckInfo
    let regex: Regex
}

extension LastCommitMessageChecker: Checker {
    func performCheck() -> [Violation] {
        [] // TODO: [cg_2020-03-14] not yet implemented
    }
}
