//
//  BitbucketOAuthConfiguration.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Bitbucket OAuth configuration
public struct BitbucketOAuthConfiguration: GitConfiguration {

    /// API endpoint
    public var apiEndpoint: String?

    /// Access token
    public var accessToken: String?

    // TODO: @NanashiLi: What type of token is this?
    /// Token
    public let token: String

    /// Secret
    public let secret: String

    /// Scopes
    public let scopes: [String]

    /// Web endpoint
    public let webEndpoint: String

    /// Error domain
    public let errorDomain = "com.auroraeditor.models.accounts.bitbucket"

    /// Initialize Bitbucket OAuth configuration
    /// 
    /// - Parameter url: URL
    /// - Parameter webURL: Web URL
    /// - Parameter token: Token
    /// - Parameter secret: Secret
    /// - Parameter scopes: Scopes
    public init(_ url: String = bitbucketBaseURL,
                webURL: String = bitbucketWebURL,
                token: String,
                secret: String,
                scopes: [String]) {
        apiEndpoint = url
        webEndpoint = webURL
        self.token = token
        self.secret = secret
        self.scopes = []
    }

    /// Authenticate
    /// 
    /// - Returns: URL
    public func authenticate() -> URL? {
        OAuthRouter.authorize(self).URLRequest?.url
    }

    /// Basic authentication string
    /// 
    /// - Returns: String
    fileprivate func basicAuthenticationString() -> String {
        let clientIDSecretString = [token, secret].joined(separator: ":")
        let clientIDSecretData = clientIDSecretString.data(using: String.Encoding.utf8)
        let base64 = clientIDSecretData?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        return "Basic \(base64 ?? "")"
    }

    /// Basic auth config
    /// 
    /// - Returns: URLSessionConfiguration
    public func basicAuthConfig() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Authorization": basicAuthenticationString()]
        return config
    }

    /// Authorize
    /// 
    /// - Parameter session: session
    /// - Parameter code: Code
    /// - Parameter completion: What to do on completion
    public func authorize(_ session: GitURLSession,
                          code: String,
                          completion: @escaping (_ config: BitbucketTokenConfiguration) -> Void) {

        let request = OAuthRouter.accessToken(self, code).URLRequest

        if let request = request {
            let task = session.dataTaskGit(with: request) { data, response, _ in
                if let response = response as? HTTPURLResponse {
                    if response.statusCode != 200 {
                        return
                    } else {
                        if let config = self.configFromData(data) {
                            completion(config)
                        }
                    }
                }
            }
            task.resume()
        }
    }

    /// Config from data
    /// 
    /// - Parameter data: Data
    /// 
    /// - Returns: BitbucketTokenConfiguration
    private func configFromData(_ data: Data?) -> BitbucketTokenConfiguration? {
        guard let data = data else { return nil }
        do {
            guard let json = try JSONSerialization.jsonObject(with: data,
                                                              options: .allowFragments) as? [String: AnyObject] else {
                return nil
            }
            let config = BitbucketTokenConfiguration(json: json)
            return config
        } catch {
            return nil
        }
    }

    /// Handle open URL
    /// 
    /// - Parameter session: session
    /// - Parameter url: URL
    /// - Parameter completion: What to do on completion
    public func handleOpenURL(_ session: GitURLSession = URLSession.shared,
                              url: URL,
                              completion: @escaping (_ config: BitbucketTokenConfiguration) -> Void) {

        let params = url.bitbucketURLParameters()

        if let code = params["code"] {
            authorize(session, code: code) { config in
                completion(config)
            }
        }
    }

    /// Access token from response
    /// 
    /// - Parameter response: Response
    /// 
    /// - Returns: Token
    public func accessTokenFromResponse(_ response: String) -> String? {
        let accessTokenParam = response.components(separatedBy: "&").first
        if let accessTokenParam = accessTokenParam {
            return accessTokenParam.components(separatedBy: "=").last
        }
        return nil
    }
}
