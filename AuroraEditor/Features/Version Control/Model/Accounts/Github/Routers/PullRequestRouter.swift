//
//  PullRequestRouter.swift
//  Aurora Editor
//
//  Created by Nanshi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

@available(*, deprecated, renamed: "VersionControl", message: "This will be deprecated in favor of the new VersionControl Remote SDK APIs.")
/// Pull Request Router
enum PullRequestRouter: JSONPostRouter {

    /// Read Pull Request
    /// 
    /// - Parameter config: Git Configuration
    /// - Parameter owner: Owner
    /// - Parameter repository: Repository
    /// - Parameter number: Number
    case readPullRequest(GitConfiguration, String, String, String)

    /// Read Pull Requests
    /// 
    /// - Parameter config: Git Configuration
    /// - Parameter owner: Owner
    /// - Parameter repository: Repository
    /// - Parameter base: Base
    /// - Parameter head: Head
    /// - Parameter state: State
    /// - Parameter sort: Sort
    /// - Parameter direction: Direction
    case readPullRequests(GitConfiguration, String, String, String?, String?, Openness, SortType, SortDirection)

    /// HTTP Method
    var method: HTTPMethod {
        switch self {
        case .readPullRequest,
             .readPullRequests:
            return .GET
        }
    }

    /// Encoding
    var encoding: HTTPEncoding {
        switch self {
        default:
            return .url
        }
    }

    /// Configuration
    var configuration: GitConfiguration? {
        switch self {
        case let .readPullRequest(config, _, _, _): return config
        case let .readPullRequests(config, _, _, _, _, _, _, _): return config
        }
    }

    /// Parameters
    var params: [String: Any] {
        switch self {
        case .readPullRequest:
            return [:]
        case let .readPullRequests(_, _, _, base, head, state, sort, direction):
            var parameters = [
                "state": state.rawValue,
                "sort": sort.rawValue,
                "direction": direction.rawValue
            ]

            if let base = base {
                parameters["base"] = base
            }

            if let head = head {
                parameters["head"] = head
            }

            return parameters
        }
    }

    /// Path
    var path: String {
        switch self {
        case let .readPullRequest(_, owner, repository, number):
            return "repos/\(owner)/\(repository)/pulls/\(number)"
        case let .readPullRequests(_, owner, repository, _, _, _, _, _):
            return "repos/\(owner)/\(repository)/pulls"
        }
    }
}
