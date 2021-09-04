import Foundation

public enum Logger {
  public static let console: ConsoleLogger = .init()
  public static let xcode: XcodeLogger = .init()
}
