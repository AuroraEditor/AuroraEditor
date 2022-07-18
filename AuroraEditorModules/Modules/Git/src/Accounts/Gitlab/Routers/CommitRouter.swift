//
//  CommitRouter.swift
//  AuroraEditorModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

enum CommitRouter: Router {
    case readCommits(Configuration, id: String, refName: String, since: String, until: String)
    case readCommit(Configuration, id: String, sha: String)
    case readCommitDiffs(Configuration, id: String, sha: String)
    case readCommitComments(Configuration, id: String, sha: String)
    case readCommitStatuses(Configuration, id: String, sha: String, ref: String, stage: String, name: String, all: Bool)

    var configuration: Configuration? {
        switch self {
        case .readCommits(let config, nil, nil, nil, nil): return config
        case .readCommit(let config, nil, nil): return config
        case .readCommitDiffs(let config, nil, nil): return config
        case .readCommitComments(let config, nil, nil): return config
        case .readCommitStatuses(let config, nil, nil, nil, nil, nil, nil): return config
        default: return nil
        }
    }

    var method: HTTPMethod {
        .GET
    }

    var encoding: HTTPEncoding {
        .url
    }

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
        default:
            return [:]
        }
    }

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
        default:
            return ""
        }
    }
}
