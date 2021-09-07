import Foundation
import Core

public final class TestLogger: Loggable {
  public var loggedMessages: [String]
  public var exitStatusCode: Int32?

  public init() {
    loggedMessages = []
  }

  public func message(_ message: String, level: PrintLevel, location: Location?) {
    if let location = location {
      loggedMessages.append(
        "[\(level.rawValue)] \(location.locationMessage(pathType: .relative)) \(message)"
      )
    }
    else {
      loggedMessages.append(
        "[\(level.rawValue)] \(message)"
      )
    }
  }

  public func exit(fail: Bool) -> Never {
    exitStatusCode = fail ? EXIT_FAILURE : EXIT_SUCCESS
    fatalError()
  }
}
