import Foundation
import Core

final class TestLogger: Loggable {
  var loggedMessages: [String] = []

  func message(_ message: String, level: PrintLevel, fileLocation: Location?) {
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
