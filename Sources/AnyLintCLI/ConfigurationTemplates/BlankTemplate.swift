import Foundation
import Utility

// swiftlint:disable function_body_length

enum BlankTemplate: ConfigurationTemplate {
  static func fileContents() -> String {
    #"""
    CheckFileContents:
      - id: Readme
        hint: 'Each project should have a README.md file, explaining how to use or contribute to the project.'
        regex: '^README\.md$'
        violateIfNoMatchesFound: true
        matchingExamples: ['README.md']
        nonMatchingExamples: ['README.markdown', 'Readme.md', 'ReadMe.md']

      - id: ReadmeTopLevelTitle
        hint: 'The README.md file should only contain a single top level title.'
        regex: '(^|\n)#[^#](.*\n)*\n#[^#]'
        includeFilter: ['^README\.md$']
        matchingExamples:
          - |
            # Title
            ## Subtitle
            Lorem ipsum

            # Other Title
            ## Other Subtitle
        nonMatchingExamples:
          - |
            # Title
            ## Subtitle
            Lorem ipsum #1 and # 2.

            ## Other Subtitle
            ### Other Subsubtitle

      - id: ReadmeTypoLicense
        hint: 'ReadmeTypoLicense: Misspelled word `license`.'
        regex: '([\s#]L|l)isence([\s\.,:;])'
        matchingExamples: [' lisence:', '## Lisence\n']
        nonMatchingExamples: [' license:', '## License\n']
        includeFilters: ['^README\.md$']
        autoCorrectReplacement: '$1icense$2'
        autoCorrectExamples:
          - { before: ' lisence:', after: ' license:' }
          - { before: '## Lisence\n', after: '## License\n' }

    CheckFilePaths:
      - id: 'ReadmePath'
        hint: 'The README file should be named exactly `README.md`.'
        regex: '^(.*/)?([Rr][Ee][Aa][Dd][Mm][Ee]\.markdown|readme\.md|Readme\.md|ReadMe\.md)$'
        matchingExamples: ['README.markdown', 'readme.md', 'ReadMe.md']
        nonMatchingExamples: ['README.md', 'CHANGELOG.md', 'CONTRIBUTING.md', 'api/help.md']
        autoCorrectReplacement: '$1README.md'
        autoCorrectExamples:
          - { before: 'api/readme.md', after: 'api/README.md' }
          - { before: 'ReadMe.md', after: 'README.md' }
          - { before: 'README.markdown', after: 'README.md' }

    """#
  }
}
