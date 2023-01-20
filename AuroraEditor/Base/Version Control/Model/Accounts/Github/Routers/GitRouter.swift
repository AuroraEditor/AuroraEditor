//
//  GitRouter.swift
//  Aurora Editor
//
//  Created by Nanshi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

enum GitRouter: JSONPostRouter {
    case deleteReference(GitConfiguration, String, String, String)

    var configuration: GitConfiguration? {
        switch self {
        case let .deleteReference(config, _, _, _): return config
        }
    }

    var method: HTTPMethod {
        switch self {
        case .deleteReference:
            return .DELETE
        }
    }

    var encoding: HTTPEncoding {
        switch self {
        case .deleteReference:
            return .url
        }
    }

    var params: [String: Any] {
        switch self {
        case .deleteReference:
            return [:]
        }
    }

    var path: String {
        switch self {
        case let .deleteReference(_, owner, repo, reference):
            return "repos/\(owner)/\(repo)/git/refs/\(reference)"
        }
    }
}
