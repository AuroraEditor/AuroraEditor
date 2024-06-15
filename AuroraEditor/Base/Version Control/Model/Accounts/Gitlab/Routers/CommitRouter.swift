//
//  CommitRouter.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Commit Router
enum CommitRouter: Router {

    /// Read commits
    /// 
    /// - Parameter config: Git Configuration
    /// - Parameter id: Identifier
    /// - Parameter refName: Ref name
    /// - Parameter since: Since
    /// - Parameter until: Until
    case readCommits(GitConfiguration, id: String, refName: String, since: String, until: String)

    /// Read commit
    /// 
    /// - Parameter config: Git Configuration
    /// - Parameter id: Identifier
    /// - Parameter sha: SHA
    case readCommit(GitConfiguration, id: String, sha: String)

    /// Read commit diffs
    /// 
    /// - Parameter config: Git Configuration
    /// - Parameter id: Identifier
    /// - Parameter sha: SHA
    case readCommitDiffs(GitConfiguration, id: String, sha: String)

    /// Read commit comments
    /// 
    /// - Parameter config: Git Configuration
    /// - Parameter id: Identifier
    /// - Parameter sha: SHA
    case readCommitComments(GitConfiguration, id: String, sha: String)

    /// Read commit statuses
    /// 
    /// - Parameter config: Git Configuration
    /// - Parameter id: Identifier
    /// - Parameter sha: SHA
    /// - Parameter ref: Ref
    /// - Parameter stage: Stage
    /// - Parameter name: Name
    /// - Parameter all: All
    case readCommitStatuses(GitConfiguration, id: String, sha: String, ref: String, stage: String, name: String, all: Bool)
    // swiftlint:disable:previous line_length

    /// Configuration
    var configuration: GitConfiguration? {
        switch self {
        case .readCommits(let config, _, _, _, _): return config
        case .readCommit(let config, _, _): return config
        case .readCommitDiffs(let config, _, _): return config
        case .readCommitComments(let config, _, _): return config
        case .readCommitStatuses(let config, _, _, _, _, _, _): return config
        }
    }

    /// HTTP Method
    var method: HTTPMethod {
        .GET
    }

    /// HTTP Encoding
    var encoding: HTTPEncoding {
        .url
    }

    /// Parameters
    var params: [String: Any] {
        switch self {
        case let .readCommits(_, _, refName, since, until):
            return ["ref_name": refName, "since": since, "until": until]
        case .readCommit:
            return [:]
        case .readCommitDiffs:
            return [:]
        case .readCommitComments:
            return [:]
        case let .readCommitStatuses(_, _, _, ref, stage, name, all):
            return ["ref": ref, "stage": stage, "name": name, "all": String(all)]
        }
    }

    /// Path
    var path: String {
        switch self {
        case let .readCommits(_, id, _, _, _):
            return "project/\(id)/repository/commits"
        case let .readCommit(_, id, sha):
            return "project/\(id)/repository/commits/\(sha)"
        case let .readCommitDiffs(_, id, sha):
            return "project/\(id)/repository/commits/\(sha)/diff"
        case let .readCommitComments(_, id, sha):
            return "project/\(id)/repository/commits/\(sha)/comments"
        case let .readCommitStatuses(_, id, sha, _, _, _, _):
            return "project/\(id)/repository/commits/\(sha)/statuses"
        }
    }
}
