import Foundation

extension Array where Element == String {
   func containsLine(at indexes: [Int], matchingRegex regex: Regex) -> Bool {
      indexes.contains { index in
         guard index >= 0, index < count else { return false }
         return regex.matches(self[index])
      }
   }
}
