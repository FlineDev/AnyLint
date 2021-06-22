import AnyLint
import Foundation
import Utility

struct LintConfiguration: Codable {
  enum CodingKeys: String, CodingKey {
    case checkFileContents = "CheckFileContents"
    case checkFilePaths = "CheckFilePaths"
  }

  let checkFileContents: [CheckFileContentsConfiguration]
  let checkFilePaths: [CheckFilePathsConfiguration]
}

struct CheckFileContentsConfiguration: Codable {
  let id: String
  let hint: String
  let regex: String
  let matchingExamples: [String]?
  let nonMatchingExamples: [String]?
  let includeFilters: [Regex]?
  let excludeFilters: [Regex]?
  let autoCorrectReplacement: String?
  let autoCorrectExamples: [AutoCorrection]?
  let repeatIfAutoCorrected: Bool?
}

struct CheckFilePathsConfiguration: Codable {
  let id: String
  let hint: String
  let regex: String
  let matchingExamples: [String]?
  let nonMatchingExamples: [String]?
  let includeFilters: [Regex]?
  let excludeFilters: [Regex]?
  let autoCorrectReplacement: String?
  let autoCorrectExamples: [AutoCorrection]?
  let violateIfNoMatchesFound: Bool?
}
