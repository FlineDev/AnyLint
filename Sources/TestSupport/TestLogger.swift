import Foundation
import Core

public final class TestLogger: Loggable {
  public var loggedMessages: [String]

  public init() {
    loggedMessages = []
  }

  public func message(_ message: String, level: PrintLevel, fileLocation: Location?) {
    if let fileLocation = fileLocation {
      loggedMessages.append(
        "[\(level.rawValue)] \(fileLocation.locationMessage(pathType: .relative)) \(message)"
      )
    }
    else {
      loggedMessages.append(
        "[\(level.rawValue)] \(message)"
      )
    }
  }
}
