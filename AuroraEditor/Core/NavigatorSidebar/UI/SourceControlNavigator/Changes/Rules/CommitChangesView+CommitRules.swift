//
//  CommitChangesView+CommitRules.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/20.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Version_Control

extension CommitChangesView {

    internal func updateRepoRuleFailures(
        forceUpdate: Bool = false
    ) async {
        if forceUpdate {
            repoRulesEnabled = RepoRulesParser().useRepoRulesLogic(
                versionControl: versionControl
            )
        }

        if !repoRulesEnabled {
            return
        }

        updateRepoRulesCommitMessageFailues(forceUpdate: forceUpdate)
        updateRepoRulesCommitAuthorFailures(forceUpdate: forceUpdate)
        updateRepoRulesBranchNameFailures(forceUpdate: forceUpdate)
    }

    private func updateRepoRulesCommitMessageFailues(
        forceUpdate: Bool = false
    ) {
        if forceUpdate {
            let commitContext: CommitContext = CommitContext(
                summary: summaryText,
                description: descriptionText,
                amend: commitToAmend != nil,
                trailers: coAuthorTrailers
            )

            let commitMessage = CommitMessageFormatter().formatCommitMessage(
                directoryURL: workspace.folderURL,
                context: commitContext
            )

            let failures = repoRulesInfo?.commitMessagePatterns.getFailedRules(commitMessage)

            // We end the call here since the failues are nil
            // no need to update the UI state and use resources
            guard let failures = failures else {
                return
            }

            repoRuleCommitMessageFailures = failures
        }
    }

    private func updateRepoRulesCommitAuthorFailures(
        forceUpdate: Bool = false
    ) {
        if forceUpdate {
            let email = versionControl.workspaceEmail
            var failures: RepoRulesMetadataFailures

            if email.isEmpty {
                failures = RepoRulesMetadataFailures()
            } else {
                failures = repoRulesInfo?.commitAuthorEmailPatterns.getFailedRules(email) ?? RepoRulesMetadataFailures()
            }

            repoRuleCommitAuthorFailures = failures
        }
    }

    private func updateRepoRulesBranchNameFailures(
        forceUpdate: Bool = false
    ) {
        if forceUpdate {
            let branch = versionControl.currentWorkspaceBranch
            var failures: RepoRulesMetadataFailures

            if branch.isEmpty {
                failures = RepoRulesMetadataFailures()
            } else {
                failures = repoRulesInfo?.branchNamePatterns.getFailedRules(branch)
                ?? RepoRulesMetadataFailures()
            }

            repoRuleBranchNameFailures = failures
        }
    }
}
