import Foundation
import Core
import Rainbow

public final class TestLogger: Loggable {
  public var loggedMessages: [String]
  public var exitStatusCode: Int32?

  public init() {
    loggedMessages = []
  }

  public func message(_ message: String, level: PrintLevel, location: Location?) {
    if let location = location {
      loggedMessages.append(
        "[\(level.rawValue)] \(location.locationMessage(pathType: .relative)) \(message.clearColor.clearStyles)"
      )
    }
    else {
      loggedMessages.append(
        "[\(level.rawValue)] \(message.clearColor.clearStyles)"
      )
    }
  }

  public func exit(fail: Bool) -> Never {
    exitStatusCode = fail ? EXIT_FAILURE : EXIT_SUCCESS
    fatalError()
  }
}
