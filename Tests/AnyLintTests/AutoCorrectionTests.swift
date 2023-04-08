@testable import AnyLint
import XCTest

final class AutoCorrectionTests: XCTestCase {
   func testInitWithDictionaryLiteral() {
      let autoCorrection: AutoCorrection = ["before": "Lisence", "after": "License"]
      XCTAssertEqual(autoCorrection.before, "Lisence")
      XCTAssertEqual(autoCorrection.after, "License")
   }
   
   func testAppliedMessageLines() {
      let singleLineAutoCorrection: AutoCorrection = ["before": "Lisence", "after": "License"]
      XCTAssertEqual(
         singleLineAutoCorrection.appliedMessageLines,
         [
            "Autocorrection applied, the diff is: (+ added, - removed)",
            "- Lisence",
            "+ License",
         ]
      )
      
      let multiLineAutoCorrection: AutoCorrection = [
         "before": "A\nB\nC\nD\nE\nF\nG\nH\nI\nJ\nK\nL\nM\nN\nO\nP\nQ\nR\nS\nT\nU\nV\nW\nX\nY\nZ\n",
         "after": "A\nB\nD\nE\nF1\nF2\nG\nH\nI\nJ\nK\nL\nM\nN\nO\nP\nQ\nR\nS\nT\nU\nV\nW\nX\nY\nZ\n",
      ]
      XCTAssertEqual(
         multiLineAutoCorrection.appliedMessageLines,
         [
            "Autocorrection applied, the diff is: (+ added, - removed)",
            "- [L3] C",
            "+ [L5] F1",
            "- [L6] F",
            "+ [L6] F2",
         ]
      )
   }
}
