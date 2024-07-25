//
//  RepoRulesMetadataFailures.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/19.
//  Copyright © 2024 Aurora Company. All rights reserved.
//


struct RepoRulesMetadataFailure: Codable {
    let description: String
    let rulesetId: Int
}

enum RepoRulesMetadataStatus: String {
    case pass
    case bypass
    case fail
}

class RepoRulesMetadataFailures {
    var failed: [RepoRulesMetadataFailure] = []
    var bypassed: [RepoRulesMetadataFailure] = []

    /// Returns the status of the rule based on its failures.
    /// 'pass' means all rules passed, 'bypass' means some rules failed
    /// but the user can bypass all of the failures, and 'fail' means
    /// at least one rule failed that the user cannot bypass.
    var status: RepoRulesMetadataStatus {
        if failed.isEmpty {
            if bypassed.isEmpty {
                return .pass
            }
            return .bypass
        }
        return .fail
    }
}
