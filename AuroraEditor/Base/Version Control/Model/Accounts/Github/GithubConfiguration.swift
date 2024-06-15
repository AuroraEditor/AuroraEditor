//
//  GithubConfiguration.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@available(*, deprecated, renamed: "VersionControl", message: "This will be deprecated in favor of the new VersionControl Remote SDK APIs.")
/// Github token configuration
public struct GithubTokenConfiguration: GitConfiguration {

    /// API Endpoint
    public var apiEndpoint: String?

    /// Access Token
    public var accessToken: String?

    /// Error Domain
    public let errorDomain: String? = "com.auroraeditor.models.accounts.github"

    /// Authorization Header
    public let authorizationHeader: String? = "Basic"

    /// Custom `Accept` header for API previews.
    ///
    /// Used for preview support of new APIs, for instance Reaction API.
    /// see: https://developer.github.com/changes/2016-05-12-reactions-api-preview/
    private var previewCustomHeaders: [HTTPHeader]?

    /// Custom Headers
    public var customHeaders: [HTTPHeader]? {
        /// More (non-preview) headers can be appended if needed in the future
        return previewCustomHeaders
    }

    /// Initialize Github Token Configuration
    /// 
    /// - Parameter token: Token
    /// - Parameter url: URL
    /// - Parameter previewHeaders: Preview Headers
    /// 
    /// - Returns: Github Token Configuration
    public init(_ token: String? = nil, url: String = githubBaseURL, previewHeaders: [PreviewHeader] = []) {
        apiEndpoint = url
        accessToken = token?.data(using: .utf8)!.base64EncodedString()
        previewCustomHeaders = previewHeaders.map { $0.header }
    }
}

/// Github OAuth Configuration
public struct OAuthConfiguration: GitConfiguration {

    /// API Endpoint
    public var apiEndpoint: String?

    /// Access Token
    public var accessToken: String?

    /// Token
    public let token: String

    /// Secret
    public let secret: String

    /// Scopes
    public let scopes: [String]

    /// Web Endpoint
    public let webEndpoint: String

    /// Error Domain
    public let errorDomain = "com.auroraeditor.models.accounts.github"

    /// Custom `Accept` header for API previews.
    ///
    /// Used for preview support of new APIs, for instance Reaction API.
    /// see: https://developer.github.com/changes/2016-05-12-reactions-api-preview/
    private var previewCustomHeaders: [HTTPHeader]?

    /// Custom Headers
    public var customHeaders: [HTTPHeader]? {
        /// More (non-preview) headers can be appended if needed in the future
        return previewCustomHeaders
    }

    /// Initialize OAuth Configuration
    /// 
    /// - Parameter url: URL
    /// - Parameter webURL: Web URL
    /// - Parameter token: Token
    /// - Parameter secret: Secret
    /// - Parameter scopes: Scopes
    /// - Parameter previewHeaders: Preview Headers
    /// 
    /// - Returns: OAuth Configuration
    public init(_ url: String = githubBaseURL,
                webURL: String = githubWebURL,
                token: String,
                secret: String,
                scopes: [String],
                previewHeaders: [PreviewHeader] = []) {

        apiEndpoint = url
        webEndpoint = webURL
        self.token = token
        self.secret = secret
        self.scopes = scopes
        previewCustomHeaders = previewHeaders.map { $0.header }
    }

    /// Authenticate
    /// 
    /// - Returns: URL
    public func authenticate() -> URL? {
        GithubOAuthRouter.authorize(self).URLRequest?.url
    }

    /// Authorize
    /// 
    /// - Parameter session: GitURLSession
    /// - Parameter code: Code
    /// - Parameter completion: Completion
    public func authorize(
        _ session: GitURLSession = URLSession.shared,
        code: String,
        completion: @escaping (_ config: GithubTokenConfiguration) -> Void) {

        let request = GithubOAuthRouter.accessToken(self, code).URLRequest
        if let request = request {
            let task = session.dataTaskGit(with: request) { data, response, _ in
                if let response = response as? HTTPURLResponse {
                    if response.statusCode != 200 {
                        return
                    } else {
                        if let data = data, let string = String(data: data, encoding: .utf8) {
                            let accessToken = self.accessTokenFromResponse(string)
                            if let accessToken = accessToken {
                                let config = GithubTokenConfiguration(accessToken, url: self.apiEndpoint ?? "")
                                completion(config)
                            }
                        }
                    }
                }
            }
            task.resume()
        }
    }

    /// Handle Open URL
    /// 
    /// - Parameter session: GitURLSession
    /// - Parameter url: URL
    /// - Parameter completion: Completion
    public func handleOpenURL(
        _ session: GitURLSession = URLSession.shared,
        url: URL,
        completion: @escaping (_ config: GithubTokenConfiguration) -> Void) {

        if let code = url.URLParameters["code"] {
            authorize(session, code: code) { config in
                completion(config)
            }
        }
    }

    /// Access Token From Response
    /// 
    /// - Parameter response: Response
    /// 
    /// - Returns: Access Token
    public func accessTokenFromResponse(_ response: String) -> String? {
        let accessTokenParam = response.components(separatedBy: "&").first
        if let accessTokenParam = accessTokenParam {
            return accessTokenParam.components(separatedBy: "=").last
        }
        return nil
    }
}

/// Github OAuth Router
enum GithubOAuthRouter: Router {

    /// Authorize
    /// 
    /// - Parameter config: OAuth Configuration
    case authorize(OAuthConfiguration)

    /// Access Token
    /// 
    /// - Parameter config: OAuth Configuration
    /// - Parameter code: Code
    case accessToken(OAuthConfiguration, String)

    /// Configuration
    var configuration: GitConfiguration? {
        switch self {
        case let .authorize(config): return config
        case let .accessToken(config, _): return config
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

    /// Encoding
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
            return "login/oauth/authorize"
        case .accessToken:
            return "login/oauth/access_token"
        }
    }

    /// Parameters
    var params: [String: Any] {
        switch self {
        case let .authorize(config):
            let scope = (config.scopes as NSArray).componentsJoined(by: ",")
            return ["scope": scope, "client_id": config.token, "allow_signup": "false"]
        case let .accessToken(config, code):
            return ["client_id": config.token, "client_secret": config.secret, "code": code]
        }
    }

    #if canImport(FoundationNetworking)
    typealias FoundationURLRequestType = FoundationNetworking.URLRequest
    #else
    typealias FoundationURLRequestType = Foundation.URLRequest
    #endif

    /// URL Request
    var URLRequest: FoundationURLRequestType? {
        switch self {
        case let .authorize(config):
            let url = URL(string: path, relativeTo: URL(string: config.webEndpoint)!)
            let components = URLComponents(url: url!, resolvingAgainstBaseURL: true)
            return request(components!, parameters: params)
        case let .accessToken(config, _):
            let url = URL(string: path, relativeTo: URL(string: config.webEndpoint)!)
            let components = URLComponents(url: url!, resolvingAgainstBaseURL: true)
            return request(components!, parameters: params)
        }
    }
}
