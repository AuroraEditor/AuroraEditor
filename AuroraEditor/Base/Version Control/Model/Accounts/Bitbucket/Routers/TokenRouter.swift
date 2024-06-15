//
//  TokenRouter.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Token router
public enum TokenRouter: Router {

    /// Refresh token
    /// 
    /// - Parameter configuration: Bitbucket OAuth configuration
    /// - Parameter token: Token
    case refreshToken(BitbucketOAuthConfiguration, String)

    /// Empty token
    /// 
    /// - Parameter configuration: Bitbucket OAuth configuration
    /// - Parameter token: Token
    case emptyToken(BitbucketOAuthConfiguration, String)

    /// Git configuration
    public var configuration: GitConfiguration? {
        switch self {
        case .refreshToken(let config, _):
            return config
        default:
            return nil
        }
    }

    /// HTTP method
    public var method: HTTPMethod {
        .POST
    }

    /// Encoding
    public var encoding: HTTPEncoding {
        .form
    }

    /// Parameters
    public var params: [String: Any] {
        switch self {
        case let .refreshToken(_, token):
            return ["refresh_token": token, "grant_type": "refresh_token"]
        default: return ["": ""]
        }
    }

    /// Path
    public var path: String {
        switch self {
        case .refreshToken:
            return "site/oauth2/access_token"
        default: return ""
        }
    }

    /// URLRequest
    public var URLRequest: Foundation.URLRequest? {
        switch self {
        case .refreshToken(let config, _):
            let url = URL(string: path, relativeTo: URL(string: config.webEndpoint)!)
            let components = URLComponents(url: url!, resolvingAgainstBaseURL: true)
            return request(components!, parameters: params)
        default: return nil
        }
    }
}
