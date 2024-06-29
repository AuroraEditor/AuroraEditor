//
//  UserRouter.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

@available(*, deprecated, renamed: "VersionControl", message: "This will be deprecated in favor of the new VersionControl Remote SDK APIs.")
/// User Router
enum UserRouter: Router {

    /// Read Authenticated User
    /// 
    /// - Parameter config: Git Configuration
    case readAuthenticatedUser(GitConfiguration)

    /// Configuration
    var configuration: GitConfiguration? {
        switch self {
        case .readAuthenticatedUser(let config): return config
        }
    }

    /// HTTP Method
    var method: HTTPMethod {
        .GET
    }

    /// HTTP Encoding
    var encoding: HTTPEncoding {
        .url
    }

    /// Path
    var path: String {
        switch self {
        case .readAuthenticatedUser:
            return "user"
        }
    }

    /// Parameters
    var params: [String: Any] {
        [:]
    }
}
