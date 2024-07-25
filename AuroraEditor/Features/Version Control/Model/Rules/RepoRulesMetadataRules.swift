//
//  RepoRulesMetadataRules.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/19.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

/// Metadata restrictions for a specific type of rule, as multiple can
/// be configured at once and all apply to the branch.
class RepoRulesMetadataRules {
    private var rules: [IRepoRulesMetadataRule] = []

    func push(_ rule: IRepoRulesMetadataRule?) {
        guard let rule = rule else {
            return
        }
        rules.append(rule)
    }

    /// Whether any rules are configured.
    var hasRules: Bool {
        return !rules.isEmpty
    }

    /// Gets an object containing arrays of human-readable rules that
    /// fail to match the provided input string. If the returned object
    /// contains only empty arrays, then all rules pass.
    public func getFailedRules(_ toMatch: String) -> RepoRulesMetadataFailures {
        let failures = RepoRulesMetadataFailures()
        for rule in rules {
            if !rule.matcher(toMatch) {
                switch rule.enforced {
                case .bypass:
                    failures.bypassed.append(
                        RepoRulesMetadataFailure(
                            description: rule.humanDescription,
                            rulesetId: rule.rulesetId
                        )
                    )
                case .enforced:
                    failures.failed.append(
                        RepoRulesMetadataFailure(
                            description: rule.humanDescription,
                            rulesetId: rule.rulesetId
                        )
                    )
                }
            }
        }
        return failures
    }
}
