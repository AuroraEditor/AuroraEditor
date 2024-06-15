//
//  GithubRepositoryRouter.swift
//  Aurora Editor
//
//  Created by Nanshi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

@available(*, deprecated, renamed: "VersionControl", message: "This will be deprecated in favor of the new VersionControl Remote SDK APIs.")
/// Github Repository Router
enum GithubRepositoryRouter: Router {

    /// Read Repositories
    /// 
    /// - Parameter config: Git Configuration
    /// - Parameter owner: Owner
    /// - Parameter page: Page
    /// - Parameter perPage: Per Page
    case readRepositories(GitConfiguration, String, String, String)

    /// Read Authenticated Repositories
    /// 
    /// - Parameter config: Git Configuration
    /// - Parameter page: Page
    /// - Parameter perPage: Per Page
    case readAuthenticatedRepositories(GitConfiguration, String, String)

    /// Read Repository
    /// 
    /// - Parameter config: Git Configuration
    /// - Parameter owner: Owner
    /// - Parameter name: Name
    case readRepository(GitConfiguration, String, String)

    /// Configuration
    var configuration: GitConfiguration? {
        switch self {
        case let .readRepositories(config, _, _, _): return config
        case let .readAuthenticatedRepositories(config, _, _): return config
        case let .readRepository(config, _, _): return config
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

    /// Parameters
    var params: [String: Any] {
        switch self {
        case let .readRepositories(_, _, page, perPage):
            return ["per_page": perPage, "page": page]
        case let .readAuthenticatedRepositories(_, page, perPage):
            return ["per_page": perPage, "page": page]
        case .readRepository:
            return [:]
        }
    }

    /// Path
    var path: String {
        switch self {
        case let .readRepositories(_, owner, _, _):
            return "users/\(owner)/repos"
        case .readAuthenticatedRepositories:
            return "user/repos"
        case let .readRepository(_, owner, name):
            return "repos/\(owner)/\(name)"
        }
    }
}
