import Foundation
import Core
import Configuration
import Reporting

protocol OptionsStringConvertible {
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
