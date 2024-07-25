//
//  RepoRulesMetadataFailureList.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/20.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import SwiftUI

/// A SwiftUI View that displays a list of metadata failures for repository rules.
///
/// This view shows failed and bypassed rules for a repository branch, with an option to view all rulesets for the branch.
struct RepoRulesMetadataFailureList: View {

    /// The metadata failures associated with the repository rules.
    @State
    var failures: RepoRulesMetadataFailures

    /// The leading text to be displayed before the failure summary.
    @State
    var leadingText: String

    /// The shared version control model.
    @EnvironmentObject
    private var versionControl: VersionControlModel

    var body: some View {
        VStack(
            alignment: .leading
        ) {
            let markdownText = """
\(leadingText) fails \(totalFails) rule\(totalFails > 1 ? "s" : "")\(endText) View all rulesets for this branch.
"""
            let tappableText = "View all rulesets for this branch."
            let tappableRange = (markdownText as NSString).range(of: tappableText)

            MarkdownTextViewRepresentable(
                markdownText: markdownText,
                tappableRanges: [tappableRange]) { tappedText in
                    if let url = URL(string: repoRulesetsForBranchLink) {
                        NSWorkspace.shared.open(url)
                    }
                }

            if !failures.failed.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Failed \(rulesText):").bold()
                    renderRuleFailureList(failures.failed)
                }
            }

            if !failures.bypassed.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Bypassed \(rulesText):").bold()
                    renderRuleFailureList(failures.bypassed)
                }
            }
        }
        .padding()
    }

    /// The total number of failed and bypassed rules.
    private var totalFails: Int {
        failures.failed.count + failures.bypassed.count
    }

    /// The text to be displayed for rules.
    private var rulesText: String {
        return "rules"
    }

    /// The text to be displayed at the end of the failure summary.
    private var endText: String {
        if failures.status == .bypass {
            return ", but you can bypass \(totalFails == 1 ? "it" : "them"). Proceed with caution!"
        } else {
            return "."
        }
    }

    /// The URL for viewing all rulesets for the current branch.
    private var repoRulesetsForBranchLink: String {
        var urlComponents = URLComponents(string: "https://github.com/\(versionControl.repository)")
        urlComponents?.path = "/rules/"
        urlComponents?.queryItems = [
            URLQueryItem(name: "ref", value: "refs/heads/\(versionControl.currentWorkspaceBranch)")
        ]

        return urlComponents?.url?.absoluteString ?? "https://github.com"
    }

    /// Renders a list of rule failures.
    ///
    /// - Parameter failures: An array of `RepoRulesMetadataFailure` objects representing the rule failures.
    /// - Returns: A view containing the list of rule failures.
    private func renderRuleFailureList(
        _ failures: [RepoRulesMetadataFailure]
    ) -> some View {
        VStack(alignment: .leading) {
            ForEach(failures, id: \.rulesetId) { failure in
                Text(failure.description)
            }
        }
    }
}
