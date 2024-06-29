//
//  BitbucketRepositoryRouter.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

@available(*, deprecated, renamed: "VersionControl", message: "This will be deprecated in favor of the new VersionControl Remote SDK APIs.")
/// Bitbucket repository router
public enum BitbucketRepositoryRouter: Router {

    /// Read repositories
    /// 
    /// - Parameter configuration: Git configuration
    /// - Parameter parameters: Parameters
    case readRepositories(GitConfiguration, String?, [String: String])

    /// Read repository
    /// 
    /// - Parameter configuration: Git configuration
    /// - Parameter owner: Owner
    /// - Parameter name: Name
    case readRepository(GitConfiguration, String, String)

    /// Configuration
    public var configuration: GitConfiguration? {
        switch self {
        case .readRepositories(let config, _, _): return config
        case .readRepository(let config, _, _): return config
        }
    }

    /// HTTP method
    public var method: HTTPMethod {
        .GET
    }

    /// Encoding
    public var encoding: HTTPEncoding {
        .url
    }

    /// Parameters
    public var params: [String: Any] {
        switch self {
        case .readRepositories(_, let userName, var nextParameters):
            if userName != nil {
                return nextParameters as [String: Any]
            } else {
                nextParameters += ["role": "member"]
                return nextParameters as [String: Any]
            }
        case .readRepository:
            return [:]
        }
    }

    /// Path
    public var path: String {
        switch self {
        case .readRepositories(_, let userName, _):
            if let userName = userName {
                return "repositories/\(userName)"
            } else {
                return "repositories"
            }
        case let .readRepository(_, owner, name):
            return "repositories/\(owner)/\(name)"
        }
    }
}
