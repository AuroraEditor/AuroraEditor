//
//  Untitled.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/20.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Version_Control
import ObjectiveC
import SwiftUI
import OSLog

struct RepoBranchRules {

    let logger = Logger(subsystem: "com.auroraeditor", category: "RepoBranchRules")

    /// Checks repo rules to see if the provided branch name is valid for the
    /// current user and repository. The "get all rules for a branch" endpoint
    /// is called first, and if a "creation" or "branch name" rule is found,
    /// then those rulesets are checked to see if the current user can bypass
    /// them.
    public func checkBranchRules(branchName: String,
                                 repository: String,
                                 workspaceURL: URL,
                                 ruleErrorMessage: Binding<String>,
                                 ruleErrorIsWarning: Binding<Bool>,
                                 versionControl: VersionControlModel) {
        if branchName.isEmpty ||
            versionControl.currentWorkspaceBranch != branchName ||
            versionControl.workspaceProvider != .github {
            return
        }

        let splitRepository = versionControl.repository.split(separator: "/")

        guard splitRepository.count == 2 else {
            logger.error("Error: Repository string is not in the expected format 'owner/name'.")
            return
        }

        let repositoryOwner = String(splitRepository[0])
        let repositoryName = String(splitRepository[1])

        let githubApi = GitHubAPI()
        githubApi.fetchRepoRulesForBranch(
            owner: repositoryOwner,
            name: repositoryName,
            branch: branchName) { branchRules in
                // Make sure user branch name hasn't changed during api call
                if branchName != versionControl.currentWorkspaceBranch {
                    return
                }

                // Filter and map the rules to extract the ruleset IDs
                let toCheck = Set(
                    branchRules?.filter { rule in
                        rule.type == APIRepoRuleType.creation ||
                        rule.type == APIRepoRuleType.branch_name_pattern
                    }
                    .map { $0.ruleset_id } ?? []
                )

                // there are no relevant rules for this branch name, so return
                if toCheck.isEmpty {
                    logger.debug("No relevant rules for this branch name")
                    return
                }

                let parsedRules = RepoRulesParser().parseRepoRules(
                    rules: branchRules ?? [],
                    rulesets: [:],
                    workspaceURL: workspaceURL
                )

                // Make sure user branch name hasn't changed during parsing of repo rules
                if versionControl.currentWorkspaceBranch != branchName {
                    return
                }

                let failedRules = parsedRules.branchNamePatterns.getFailedRules(branchName)

                // Only possible kind of failures is branch name pattern failures and creation restriction
                if parsedRules.creationRestricted != .enforced(true) && failedRules.status == .pass {
                    return
                }

                var cannotBypass = false
                for id in toCheck {
                    let cachedRulesets = versionControl.cachedRepoRulesets[id]

                    if cachedRulesets?.current_user_can_bypass != .always {
                        // the user cannot bypass, so stop checking
                        cannotBypass = true
                        break
                    }
                }

                if cannotBypass {
                    ruleErrorMessage.wrappedValue = "Branch name \(branchName) is restricted by repo rules."
                    ruleErrorIsWarning.wrappedValue = false
                } else {
                    ruleErrorMessage.wrappedValue = "Branch name \(branchName) is restricted by repo rules, but you can bypass them. Proceed with caution!"
                    ruleErrorIsWarning.wrappedValue = true
                }
            }
    }
}
