//
//  BitbucketTokenConfiguration.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Bitbucket token configuration
public struct BitbucketTokenConfiguration: GitConfiguration {

    /// API endpoint
    public var apiEndpoint: String?

    /// Access token
    public var accessToken: String?

    /// Refresh token
    public var refreshToken: String?

    /// Expiration date
    public var expirationDate: Date?

    /// Error domain
    public let errorDomain = "com.auroraeditor.models.accounts.bitbucket"

    /// Initialize Bitbucket token configuration
    /// 
    /// - Parameter json: JSON
    /// - Parameter url: URL
    /// 
    /// - Returns: Bitbucket token configuration
    public init(json: [String: AnyObject], url: String = bitbucketBaseURL) {
        apiEndpoint = url
        accessToken = json["access_token"] as? String
        refreshToken = json["refresh_token"] as? String
        let expiresIn = json["expires_in"] as? Int
        let currentDate = Date()
        expirationDate = currentDate.addingTimeInterval(TimeInterval(expiresIn ?? 0))
    }

    /// Initialize Bitbucket token configuration
    /// 
    /// - Parameter token: Token
    /// - Parameter refreshToken: Refresh token
    /// - Parameter expirationDate: Expiration date
    /// - Parameter url: URL
    /// 
    /// - Returns: Bitbucket token configuration
    public init(_ token: String? = nil,
                refreshToken: String? = nil,
                expirationDate: Date? = nil,
                url: String = bitbucketBaseURL) {
        apiEndpoint = url
        accessToken = token
        self.expirationDate = expirationDate
        self.refreshToken = refreshToken
    }
}
