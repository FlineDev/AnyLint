//import Foundation
//import OrderedCollections
//import Core
//
///// A wraper for ``LintResults`` due to a Bug in Swift. (see https://bugs.swift.org/browse/SR-7788)
//public typealias CodableLintResults = CodableOrderedDictionary<Severity, CodableOrderedDictionary<Check, [Violation]>>
//
//extension CodableLintResults {
//  init(lintResults: LintResults) {
//    var newCodableSeverityDict: CodableLintResults = .init()
//
//    for (severity, checkDict) in lintResults {
//      var newCodableCheckDict: CodableOrderedDictionary<Check, [Violation]> = .init()
//
//      for (check, violations) in checkDict {
//        newCodableCheckDict.wrappedValue[check] = violations
//      }
//
//      newCodableSeverityDict.wrappedValue[severity] = newCodableCheckDict
//    }
//
//    self = newCodableSeverityDict
//  }
//
//  var lintResults: LintResults {
//    wrappedValue.mapValues { $0.wrappedValue }
//  }
//}
