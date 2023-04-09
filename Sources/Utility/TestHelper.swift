import Foundation

/// A helper class for Unit Testing only.
public final class TestHelper {
   /// The console output data.
   public typealias ConsoleOutput = (message: String, level: Logger.PrintLevel)

   /// The shared `TestHelper` object.
   public static let shared = TestHelper()

   /// Use only in Unit Tests.
   public var consoleOutputs: [ConsoleOutput] = []

   /// Use only in Unit Tests.
   public var exitStatus: Logger.ExitStatus?

   /// Deletes all data collected until now.
   public func reset() {
      consoleOutputs = []
      exitStatus = nil
   }
}
