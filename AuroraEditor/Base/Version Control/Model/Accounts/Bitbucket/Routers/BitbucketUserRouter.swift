//
//  BitbucketUserRouter.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

@available(*, deprecated, renamed: "VersionControl", message: "This will be deprecated in favor of the new VersionControl Remote SDK APIs.")
/// Bitbucket user router
public enum BitbucketUserRouter: Router {

    /// Read authenticated user
    /// 
    /// - Parameter configuration: Git configuration
    case readAuthenticatedUser(GitConfiguration)

    /// Read emails
    /// 
    /// - Parameter configuration: Git configuration
    case readEmails(GitConfiguration)

    /// Git configuration
    public var configuration: GitConfiguration? {
        switch self {
        case .readAuthenticatedUser(let config): return config
        case .readEmails(let config): return config
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

    /// Path
    public var path: String {
        switch self {
        case .readAuthenticatedUser:
            return "user"
        case .readEmails:
            return "user/emails"
        }
    }

    /// Parameters
    public var params: [String: Any] {
        [:]
    }
}
