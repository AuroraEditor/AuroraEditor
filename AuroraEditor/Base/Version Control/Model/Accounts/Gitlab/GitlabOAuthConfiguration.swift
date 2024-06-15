//
//  GitlabOAuthConfiguration.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

@available(*, deprecated, renamed: "VersionControl", message: "This will be deprecated in favor of the new VersionControl Remote SDK APIs.")
/// Gitlab OAuth Configuration
public struct GitlabOAuthConfiguration: GitConfiguration {

    /// API Endpoint
    public var apiEndpoint: String?

    /// Access Token
    public var accessToken: String?

    /// Token
    public let token: String

    /// Secret
    public let secret: String

    /// Redirect URI
    public let redirectURI: String

    /// Web Endpoint
    public let webEndpoint: String

    /// Error Domain
    public let errorDomain = "com.auroraeditor.models.accounts.gitlab"

    /// Initialize Gitlab OAuth Configuration
    /// 
    /// - Parameter url: API Endpoint
    /// - Parameter webURL: Web Endpoint
    /// - Parameter token: Token
    /// - Parameter secret: Secret
    /// - Parameter redirectURI: Redirect URI
    /// 
    /// - Returns: Gitlab OAuth Configuration
    public init(_ url: String = gitlabBaseURL,
                webURL: String = gitlabWebURL,
                token: String,
                secret: String,
                redirectURI: String) {
        apiEndpoint = url
        webEndpoint = webURL
        self.token = token
        self.secret = secret
        self.redirectURI = redirectURI
    }

    /// Authenticate
    /// 
    /// - Returns: URL
    public func authenticate() -> URL? {
        GitlabOAuthRouter.authorize(self, redirectURI).URLRequest?.url
    }

    /// Authorize
    /// 
    /// - Parameter session: Git URL Session
    /// - Parameter code: Code
    /// - Parameter completion: Completion
    public func authorize(_ session: GitURLSession = URLSession.shared,
                          code: String,
                          completion: @escaping (_ config: GitlabTokenConfiguration) -> Void) {
        let request = GitlabOAuthRouter.accessToken(self, code, redirectURI).URLRequest
        if let request = request {
            let task = session.dataTaskGit(with: request) { data, response, _ in
                if let response = response as? HTTPURLResponse {
                    if response.statusCode != 200 {
                        return
                    } else {
                        guard let data = data else {
                            return
                        }
                        do {
                            let json = try JSONSerialization.jsonObject(with: data,
                                                                        options: .allowFragments) as? [String: Any]
                            if let json = json, let accessToken = json["access_token"] as? String {
                                let config = GitlabTokenConfiguration(accessToken, url: self.apiEndpoint ?? "")
                                completion(config)
                            }
                        } catch {
                            return
                        }
                    }
                }
            }
            task.resume()
        }
    }

    /// Handle Open URL
    /// 
    /// - Parameter session: Git URL Session
    /// - Parameter url: URL
    /// - Parameter completion: Completion
    public func handleOpenURL(_ session: GitURLSession = URLSession.shared,
                              url: URL,
                              completion: @escaping (_ config: GitlabTokenConfiguration) -> Void) {
        if let code = url.absoluteString.components(separatedBy: "=").last {
            authorize(session, code: code) { (config) in
                completion(config)
            }
        }
    }
}
