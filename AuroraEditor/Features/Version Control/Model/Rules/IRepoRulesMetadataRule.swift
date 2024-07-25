//
//  IRepoRulesMetadataRule.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/20.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

typealias RepoRulesMetadataMatcher = (String) -> Bool

struct IRepoRulesMetadataRule {
    ///  Whether this rule is enforced for the current user.
    var enforced: RepoRuleEnforced
    ///  Function that determines whether the provided string matches the rule.
    var matcher: RepoRulesMetadataMatcher
    ///  Human-readable description of the rule. For example, a 'starts_with'
    ///  rule with the pattern 'abc' that is negated would have a description
    ///  of 'must not start with "abc"'.
    var humanDescription: String
    ///  ID of the ruleset this rule is configured in.
    var rulesetId: Int
}
