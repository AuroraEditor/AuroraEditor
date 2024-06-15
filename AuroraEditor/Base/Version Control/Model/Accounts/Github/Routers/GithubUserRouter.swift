//
//  GithubUserRouter.swift
//  Aurora Editor
//
//  Created by Nanshi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Github User Router
enum GithubUserRouter: Router {

    /// Read Authenticated User
    /// 
    /// - Parameter config: Git Configuration
    case readAuthenticatedUser(GitConfiguration)

    /// Read User
    /// 
    /// - Parameter username: Username
    /// - Parameter config: Git Configuration
    case readUser(String, GitConfiguration)

    /// Configuration
    var configuration: GitConfiguration? {
        switch self {
        case let .readAuthenticatedUser(config): return config
        case let .readUser(_, config): return config
        }
    }

    /// HTTP Method
    var method: HTTPMethod {
        .GET
    }

    /// Encoding
    var encoding: HTTPEncoding {
        .url
    }

    /// Path
    var path: String {
        switch self {
        case .readAuthenticatedUser:
            return "user"
        case let .readUser(username, _):
            return "users/\(username)"
        }
    }

    /// Parameters
    var params: [String: Any] {
        [:]
    }
}
