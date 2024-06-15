//
//  GitlabOAuthRouter.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Gitlab OAuth Router
enum GitlabOAuthRouter: Router {

    /// Authorize
    /// 
    /// - Parameter config: Gitlab OAuth Configuration
    /// - Parameter redirectURI: Redirect URI
    case authorize(GitlabOAuthConfiguration, String)

    /// Access Token
    /// 
    /// - Parameter config: Gitlab OAuth Configuration
    /// - Parameter code: Code
    /// - Parameter redirectURI: Redirect URI
    case accessToken(GitlabOAuthConfiguration, String, String)

    /// Configuration
    var configuration: GitConfiguration? {
        switch self {
        case .authorize(let config, _): return config
        case .accessToken(let config, _, _): return config
        }
    }

    /// HTTP Method
    var method: HTTPMethod {
        switch self {
        case .authorize:
            return .GET
        case .accessToken:
            return .POST
        }
    }

    /// HTTP Encoding
    var encoding: HTTPEncoding {
        switch self {
        case .authorize:
            return .url
        case .accessToken:
            return .form
        }
    }

    /// Path
    var path: String {
        switch self {
        case .authorize:
            return "oauth/authorize"
        case .accessToken:
            return "oauth/token"
        }
    }

    /// Parameters
    var params: [String: Any] {
        switch self {
        case let .authorize(config, redirectURI):
            return [
                "client_id": config.token as AnyObject,
                "response_type": "code" as AnyObject,
                "redirect_uri": redirectURI as AnyObject]
        case let .accessToken(config, code, redirectURI):
            return [
                "client_id": config.token as AnyObject,
                "client_secret": config.secret as AnyObject,
                "code": code as AnyObject, "grant_type":
                    "authorization_code" as AnyObject,
                "redirect_uri": redirectURI as AnyObject]
        }
    }

    /// URL Request
    var URLRequest: Foundation.URLRequest? {
        switch self {
        case .authorize(let config, _):
            let url = URL(string: path, relativeTo: URL(string: config.webEndpoint)!)
            let components = URLComponents(url: url!, resolvingAgainstBaseURL: true)
            return request(components!, parameters: params)
        case .accessToken(let config, _, _):
            let url = URL(string: path, relativeTo: URL(string: config.webEndpoint)!)
            let components = URLComponents(url: url!, resolvingAgainstBaseURL: true)
            return request(components!, parameters: params)
        }
    }
}
