//
//  RepoRuleEnforced.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/20.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

enum RepoRuleEnforced: Equatable {
    case enforced(Bool)
    case bypass

    static func == (
        lhs: RepoRuleEnforced,
        rhs: RepoRuleEnforced
    ) -> Bool {
        switch (lhs, rhs) {
        case (.enforced(let lval), .enforced(let rval)):
            return lval == rval
        case (.bypass, .bypass):
            return true
        default:
            return false
        }
    }
}
