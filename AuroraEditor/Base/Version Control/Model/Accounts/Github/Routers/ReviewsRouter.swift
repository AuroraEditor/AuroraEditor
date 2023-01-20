//
//  ReviewsRouter.swift
//  Aurora Editor
//
//  Created by Nanshi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

enum ReviewsRouter: JSONPostRouter {
    case listReviews(GitConfiguration, String, String, Int)

    var method: HTTPMethod {
        switch self {
        case .listReviews:
            return .GET
        }
    }

    var encoding: HTTPEncoding {
        switch self {
        default:
            return .url
        }
    }

    var configuration: GitConfiguration? {
        switch self {
        case let .listReviews(config, _, _, _):
            return config
        }
    }

    var params: [String: Any] {
        switch self {
        case .listReviews:
            return [:]
        }
    }

    var path: String {
        switch self {
        case let .listReviews(_, owner, repository, pullRequestNumber):
            return "repos/\(owner)/\(repository)/pulls/\(pullRequestNumber)/reviews"
        }
    }
}
