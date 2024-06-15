//
//  IssueRouter.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Issue Router
enum IssueRouter: JSONPostRouter {

    /// Read Authenticated Issues
    /// 
    /// - Parameter config: Git Configuration
    /// - Parameter page: Page
    /// - Parameter perPage: Per Page
    /// - Parameter state: State
    case readAuthenticatedIssues(GitConfiguration, String, String, Openness)

    /// Read Issue
    /// 
    /// - Parameter config: Git Configuration
    /// - Parameter owner: Owner
    /// - Parameter repository: Repository
    /// - Parameter number: Number
    case readIssue(GitConfiguration, String, String, Int)

    /// Read Issues
    /// 
    /// - Parameter config: Git Configuration
    /// - Parameter owner: Owner
    /// - Parameter repository: Repository
    /// - Parameter page: Page
    /// - Parameter perPage: Per Page
    /// - Parameter state: State
    case readIssues(GitConfiguration, String, String, String, String, Openness)

    /// Post Issue
    /// 
    /// - Parameter config: Git Configuration
    /// - Parameter owner: Owner
    /// - Parameter repository: Repository
    /// - Parameter title: Title
    /// - Parameter body: Body
    /// - Parameter assignee: Assignee
    /// - Parameter labels: Labels
    case postIssue(GitConfiguration, String, String, String, String?, String?, [String])

    /// Patch Issue
    /// 
    /// - Parameter config: Git Configuration
    /// - Parameter owner: Owner
    /// - Parameter repository: Repository
    /// - Parameter number: Number
    /// - Parameter title: Title
    /// - Parameter body: Body
    /// - Parameter assignee: Assignee
    /// - Parameter state: State
    case patchIssue(GitConfiguration, String, String, Int, String?, String?, String?, Openness?)

    /// Comment Issue
    /// 
    /// - Parameter config: Git Configuration
    /// - Parameter owner: Owner
    /// - Parameter repository: Repository
    /// - Parameter number: Number
    /// - Parameter body: Body
    case commentIssue(GitConfiguration, String, String, Int, String)

    /// Read Issue Comments
    /// 
    /// - Parameter config: Git Configuration
    /// - Parameter owner: Owner
    /// - Parameter repository: Repository
    /// - Parameter number: Number
    /// - Parameter page: Page
    /// - Parameter perPage: Per Page
    case readIssueComments(GitConfiguration, String, String, Int, String, String)

    /// Patch Issue Comment
    /// 
    /// - Parameter config: Git Configuration
    /// - Parameter owner: Owner
    /// - Parameter repository: Repository
    /// - Parameter number: Number
    /// - Parameter body: Body
    case patchIssueComment(GitConfiguration, String, String, Int, String)

    /// HTTP Method
    var method: HTTPMethod {
        switch self {
        case .postIssue, .patchIssue, .commentIssue, .patchIssueComment:
            return .POST
        default:
            return .GET
        }
    }

    /// Encoding
    var encoding: HTTPEncoding {
        switch self {
        case .postIssue, .patchIssue, .commentIssue, .patchIssueComment:
            return .json
        default:
            return .url
        }
    }

    /// Configuration
    var configuration: GitConfiguration? {
        switch self {
        case let .readAuthenticatedIssues(config, _, _, _): return config
        case let .readIssue(config, _, _, _): return config
        case let .readIssues(config, _, _, _, _, _): return config
        case let .postIssue(config, _, _, _, _, _, _): return config
        case let .patchIssue(config, _, _, _, _, _, _, _): return config
        case let .commentIssue(config, _, _, _, _): return config
        case let .readIssueComments(config, _, _, _, _, _): return config
        case let .patchIssueComment(config, _, _, _, _): return config
        }
    }

    /// Parameters
    var params: [String: Any] {
        switch self {
        case let .readAuthenticatedIssues(_, page, perPage, state):
            return ["per_page": perPage, "page": page, "state": state.rawValue]
        case .readIssue:
            return [:]
        case let .readIssues(_, _, _, page, perPage, state):
            return ["per_page": perPage, "page": page, "state": state.rawValue]
        case let .postIssue(_, _, _, title, body, assignee, labels):
            var params: [String: Any] = ["title": title]
            if let body = body {
                params["body"] = body
            }
            if let assignee = assignee {
                params["assignee"] = assignee
            }
            if !labels.isEmpty {
                params["labels"] = labels
            }
            return params
        case let .patchIssue(_, _, _, _, title, body, assignee, state):
            var params: [String: String] = [:]
            if let title = title {
                params["title"] = title
            }
            if let body = body {
                params["body"] = body
            }
            if let assignee = assignee {
                params["assignee"] = assignee
            }
            if let state = state {
                params["state"] = state.rawValue
            }
            return params
        case let .commentIssue(_, _, _, _, body):
            return ["body": body]
        case let .readIssueComments(_, _, _, _, page, perPage):
            return ["per_page": perPage, "page": page]
        case let .patchIssueComment(_, _, _, _, body):
            return ["body": body]
        }
    }

    /// Path
    var path: String {
        switch self {
        case .readAuthenticatedIssues:
            return "issues"
        case let .readIssue(_, owner, repository, number):
            return "repos/\(owner)/\(repository)/issues/\(number)"
        case let .readIssues(_, owner, repository, _, _, _):
            return "repos/\(owner)/\(repository)/issues"
        case let .postIssue(_, owner, repository, _, _, _, _):
            return "repos/\(owner)/\(repository)/issues"
        case let .patchIssue(_, owner, repository, number, _, _, _, _):
            return "repos/\(owner)/\(repository)/issues/\(number)"
        case let .commentIssue(_, owner, repository, number, _):
            return "repos/\(owner)/\(repository)/issues/\(number)/comments"
        case let .readIssueComments(_, owner, repository, number, _, _):
            return "repos/\(owner)/\(repository)/issues/\(number)/comments"
        case let .patchIssueComment(_, owner, repository, number, _):
            return "repos/\(owner)/\(repository)/issues/comments/\(number)"
        }
    }
}
