import Foundation

extension String {
    typealias LocationInfo = (line: Int, charInLine: Int)

    func locationInfo(of index: String.Index) -> LocationInfo {
        (line: 0, charInLine: 0) // TODO: [cg_2020-03-13] not yet implemented
    }
}
