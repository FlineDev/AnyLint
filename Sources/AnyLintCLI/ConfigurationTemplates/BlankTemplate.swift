import Foundation
import Utility

// swiftlint:disable function_body_length

enum BlankTemplate: ConfigurationTemplate {
    static func fileContents() -> String {
        commonPrefix + #"""
            // MARK: - Variables
            let readmeFile: Regex = #"README\.md"#

            // MARK: - Checks
            // MARK: readme
            try Lint.checkFilePaths(
                checkInfo: "readme: Each project should have a README.md file, explaining how to use or contribute to the project.",
                regex: #"^README\.md$"#,
                matchingExamples: ["README.md"],
                nonMatchingExamples: ["README.markdown", "Readme.md", "ReadMe.md"],
                violateIfNoMatchesFound: true
            )

            // MARK: readme_path
            try Lint.checkFilePaths(
                checkInfo: "readme_path: The README file should be named exactly `README.md`.",
                regex: #"^(.*/)?([Rr][Ee][Aa][Dd][Mm][Ee]\.markdown|readme\.md|Readme\.md|ReadMe\.md)$"#,
                matchingExamples: ["README.markdown", "readme.md", "ReadMe.md"],
                nonMatchingExamples: ["README.md", "CHANGELOG.md", "CONTRIBUTING.md", "api/help.md"],
                autoCorrectReplacement: "$1README.md",
                autoCorrectExamples: [
                    AutoCorrection(before: "api/readme.md", after: "api/README.md"),
                    AutoCorrection(before: "ReadMe.md", after: "README.md"),
                    AutoCorrection(before: "README.markdown", after: "README.md"),
                ]
            )

            // MARK: readme_top_level_title
            try Lint.checkFileContents(
                checkInfo: "readme_top_level_title: The README.md file should only contain a single top level title.",
                regex: #"(^|\n)#[^#](.*\n)*\n#[^#]"#,
                matchingExamples: [
                    """
                    # Title
                    ## Subtitle
                    Lorem ipsum

                    # Other Title
                    ## Other Subtitle
                    """,
                ],
                nonMatchingExamples: [
                    """
                    # Title
                    ## Subtitle
                    Lorem ipsum #1 and # 2.

                    ## Other Subtitle
                    ### Other Subsubtitle
                    """,
                ],
                includeFilters: [readmeFile]
            )

            // MARK: readme_typo_license
            try Lint.checkFileContents(
                checkInfo: "readme_typo_license: Misspelled word 'license'.",
                regex: #"([\s#]L|l)isence([\s\.,:;])"#,
                matchingExamples: [" lisence:", "## Lisence\n"],
                nonMatchingExamples: [" license:", "## License\n"],
                includeFilters: [readmeFile],
                autoCorrectReplacement: "$1icense$2",
                autoCorrectExamples: [
                    AutoCorrection(before: " lisence:", after: " license:"),
                    AutoCorrection(before: "## Lisence\n", after: "## License\n"),
                ]
            )
            """# + commonSuffix
    }
}
