//
//  GithubUserRouter.swift
//  Aurora Editor
//
//  Created by Nanshi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

enum GithubUserRouter: Router {
    case readAuthenticatedUser(GitConfiguration)
    case readUser(String, GitConfiguration)

    var configuration: GitConfiguration? {
        switch self {
        case let .readAuthenticatedUser(config): return config
        case let .readUser(_, config): return config
        }
    }

    var method: HTTPMethod {
        .GET
    }

    var encoding: HTTPEncoding {
        .url
    }

    var path: String {
        switch self {
        case .readAuthenticatedUser:
            return "user"
        case let .readUser(username, _):
            return "users/\(username)"
        }
    }

    var params: [String: Any] {
        [:]
    }
}
