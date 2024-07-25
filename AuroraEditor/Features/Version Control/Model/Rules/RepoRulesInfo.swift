//
//  RepoRulesInfo.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/19.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

/**
 * Parsed repo rule info
 */
struct RepoRulesInfo {
    /**
     * Many rules are not handled in a special way, they
     * instead just display a warning to the user when they're
     * about to commit. They're lumped together into this flag
     * for simplicity. See the `parseRepoRules` function for
     * the full list.
     */
    public var basicCommitWarning: RepoRuleEnforced = .enforced(false)

    /**
     * If true, the branch's name conflicts with a rule and
     * cannot be created.
     */
    public var creationRestricted: RepoRuleEnforced = .enforced(false)

    /**
     * Whether signed commits are required. `parseRepoRules` will
     * set this to `false` if the user has commit signing configured.
     */
    public var signedCommitsRequired: RepoRuleEnforced = .enforced(false)

    public var pullRequestRequired: RepoRuleEnforced = .enforced(false)
    public var commitMessagePatterns = RepoRulesMetadataRules()
    public var commitAuthorEmailPatterns = RepoRulesMetadataRules()
    public var committerEmailPatterns = RepoRulesMetadataRules()
    public var branchNamePatterns = RepoRulesMetadataRules()
}
