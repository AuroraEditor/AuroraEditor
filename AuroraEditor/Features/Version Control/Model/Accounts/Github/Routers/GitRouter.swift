//
//  GitRouter.swift
//  Aurora Editor
//
//  Created by Nanshi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

@available(*, deprecated, renamed: "VersionControl", message: "This will be deprecated in favor of the new VersionControl Remote SDK APIs.")
/// Git Router
enum GitRouter: JSONPostRouter {

    /// Delete Reference
    /// 
    /// - Parameter config: Git Configuration
    /// - Parameter owner: Owner
    /// - Parameter repo: Repository
    /// - Parameter reference: Reference
    case deleteReference(GitConfiguration, String, String, String)

    /// Configuration
    var configuration: GitConfiguration? {
        switch self {
        case let .deleteReference(config, _, _, _): return config
        }
    }

    /// HTTP Method
    var method: HTTPMethod {
        switch self {
        case .deleteReference:
            return .DELETE
        }
    }

    /// Encoding
    var encoding: HTTPEncoding {
        switch self {
        case .deleteReference:
            return .url
        }
    }

    /// Parameters
    var params: [String: Any] {
        switch self {
        case .deleteReference:
            return [:]
        }
    }

    /// Path
    var path: String {
        switch self {
        case let .deleteReference(_, owner, repo, reference):
            return "repos/\(owner)/\(repo)/git/refs/\(reference)"
        }
    }
}
