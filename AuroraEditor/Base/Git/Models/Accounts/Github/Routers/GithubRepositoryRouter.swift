//
//  GithubRepositoryRouter.swift
//  AuroraEditorModules/GitAccounts
//
//  Created by Nanshi Li on 2022/03/31.
//

import Foundation

enum GithubRepositoryRouter: Router {
    case readRepositories(GitConfiguration, String, String, String)
    case readAuthenticatedRepositories(GitConfiguration, String, String)
    case readRepository(GitConfiguration, String, String)

    var configuration: GitConfiguration? {
        switch self {
        case let .readRepositories(config, _, _, _): return config
        case let .readAuthenticatedRepositories(config, _, _): return config
        case let .readRepository(config, _, _): return config
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
        case let .readRepositories(_, _, page, perPage):
            return ["per_page": perPage, "page": page]
        case let .readAuthenticatedRepositories(_, page, perPage):
            return ["per_page": perPage, "page": page]
        case .readRepository:
            return [:]
        }
    }

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
