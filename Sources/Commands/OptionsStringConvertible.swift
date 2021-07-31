import Foundation
import Core
import Configuration
import Reporting

/// A protocol to output a set of configuration options when asking for help.
protocol OptionsStringConvertible {
  /// A human readable string representation of the possible options for help text.
  static var optionsDescription: String { get }
}

extension Template: OptionsStringConvertible {
  static var optionsDescription: String {
    allCases.map(\.rawValue).joined(separator: ", ")
  }
}

extension Severity: OptionsStringConvertible {
  static var optionsDescription: String {
    allCases.map(\.rawValue).joined(separator: ", ")
  }
}

extension OutputFormat: OptionsStringConvertible {
  static var optionsDescription: String {
    allCases.map(\.rawValue).joined(separator: ", ")
  }
}
