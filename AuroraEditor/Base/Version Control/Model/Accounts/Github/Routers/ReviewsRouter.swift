//
//  ReviewsRouter.swift
//  Aurora Editor
//
//  Created by Nanshi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

@available(*, deprecated, renamed: "VersionControl", message: "This will be deprecated in favor of the new VersionControl Remote SDK APIs.")
/// Reviews Router
enum ReviewsRouter: JSONPostRouter {

    /// List Reviews
    /// 
    /// - Parameter config: Git Configuration
    /// - Parameter owner: Owner
    /// - Parameter repository: Repository
    /// - Parameter pullRequestNumber: Pull Request Number
    case listReviews(GitConfiguration, String, String, Int)

    /// HTTP Method
    var method: HTTPMethod {
        switch self {
        case .listReviews:
            return .GET
        }
    }

    /// Encoding
    var encoding: HTTPEncoding {
        switch self {
        default:
            return .url
        }
    }

    /// Configuration
    var configuration: GitConfiguration? {
        switch self {
        case let .listReviews(config, _, _, _):
            return config
        }
    }

    /// Parameters
    var params: [String: Any] {
        switch self {
        case .listReviews:
            return [:]
        }
    }

    /// Path
    var path: String {
        switch self {
        case let .listReviews(_, owner, repository, pullRequestNumber):
            return "repos/\(owner)/\(repository)/pulls/\(pullRequestNumber)/reviews"
        }
    }
}
