import Foundation

struct CheckerArray: Checker {
   let checkers: [Checker]

   func performCheck() throws -> [Violation] {
      var violations: [Violation] = []

      for checker in self.checkers {
         try violations.append(contentsOf: checker.performCheck())
      }

      return violations
   }
}

struct EmptyChecker: Checker {
   func performCheck() throws -> [Violation] { [] }
}

@resultBuilder
struct CheckerBuilder {
   // add basic builder support
   static func buildBlock(_ components: Checker...) -> Checker {
      CheckerArray(checkers: components)
   }

   // add support of `if` statements
   static func buildOptional(_ component: Checker?) -> Checker {
      component ?? EmptyChecker()
   }

   // add support for `if-else` and `switch` statements
   static func buildEither(first component: Checker) -> Checker {
      component
   }

   static func buildEither(second component: Checker) -> Checker {
      component
   }

   // add support for `for..in` statements
   static func buildArray(_ components: [Checker]) -> Checker {
      CheckerArray(checkers: components)
   }
}
