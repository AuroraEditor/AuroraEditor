//
//  OAuthRouter.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

@available(*, deprecated, renamed: "VersionControl", message: "This will be deprecated in favor of the new VersionControl Remote SDK APIs.")
/// OAuth router
public enum OAuthRouter: Router {

    /// Authorize
    /// 
    /// - Parameter configuration: Bitbucket OAuth configuration
    case authorize(BitbucketOAuthConfiguration)

    /// Access token
    /// 
    /// - Parameter configuration: Bitbucket OAuth configuration
    /// - Parameter code: Code
    case accessToken(BitbucketOAuthConfiguration, String)

    /// Git configuration
    public var configuration: GitConfiguration? {
        switch self {
        case .authorize(let config): return config
        case .accessToken(let config, _): return config
        }
    }

    /// HTTP method
    public var method: HTTPMethod {
        switch self {
        case .authorize:
            return .GET
        case .accessToken:
            return .POST
        }
    }

    /// Encoding
    public var encoding: HTTPEncoding {
        switch self {
        case .authorize:
            return .url
        case .accessToken:
            return .form
        }
    }

    /// Path
    public var path: String {
        switch self {
        case .authorize:
            return "site/oauth2/authorize"
        case .accessToken:
            return "site/oauth2/access_token"
        }
    }

    /// Parameters
    public var params: [String: Any] {
        switch self {
        case .authorize(let config):
            return ["client_id": config.token, "response_type": "code"]
        case .accessToken(_, let code):
            return ["code": code, "grant_type": "authorization_code"]
        }
    }

    /// URLRequest
    public var URLRequest: Foundation.URLRequest? {
        switch self {
        case .authorize(let config):
            let url = URL(string: path, relativeTo: URL(string: config.webEndpoint)!)
            let components = URLComponents(url: url!, resolvingAgainstBaseURL: true)
            return request(components!, parameters: params)
        case .accessToken(let config, _):
            let url = URL(string: path, relativeTo: URL(string: config.webEndpoint)!)
            let components = URLComponents(url: url!, resolvingAgainstBaseURL: true)
            return request(components!, parameters: params)
        }
    }
}
