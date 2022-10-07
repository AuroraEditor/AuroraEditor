//
//  BitbucketUserRouter.swift
//  AuroraEditorModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

public enum BitbucketUserRouter: Router {
    case readAuthenticatedUser(GitConfiguration)
    case readEmails(GitConfiguration)

    public var configuration: GitConfiguration? {
        switch self {
        case .readAuthenticatedUser(let config): return config
        case .readEmails(let config): return config
        }
    }

    public var method: HTTPMethod {
        .GET
    }

    public var encoding: HTTPEncoding {
        .url
    }

    public var path: String {
        switch self {
        case .readAuthenticatedUser:
            return "user"
        case .readEmails:
            return "user/emails"
        }
    }

    public var params: [String: Any] {
        [:]
    }
}
