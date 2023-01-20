//
//  UserRouter.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

enum UserRouter: Router {
    case readAuthenticatedUser(GitConfiguration)

    var configuration: GitConfiguration? {
        switch self {
        case .readAuthenticatedUser(let config): return config
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
        }
    }

    var params: [String: Any] {
        [:]
    }
}
