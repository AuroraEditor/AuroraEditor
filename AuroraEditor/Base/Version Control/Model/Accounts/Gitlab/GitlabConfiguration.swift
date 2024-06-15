//
//  GitlabConfiguration.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Gitlab token configuration
public struct GitlabTokenConfiguration: GitConfiguration {

    /// API endpoint
    public var apiEndpoint: String?

    /// Access token
    public var accessToken: String?

    /// Error domain
    public let errorDomain: String? = "com.auroraeditor.models.accounts.gitlab"

    /// Initialize Gitlab token configuration
    /// 
    /// - Parameter token: Access token
    /// - Parameter url: API endpoint
    /// 
    /// - Returns: Gitlab token configuration
    public init(_ token: String? = nil, url: String = gitlabBaseURL) {
        apiEndpoint = url
        accessToken = token
    }
}

/// Gitlab private token configuration
public struct PrivateTokenConfiguration: GitConfiguration {

    /// API endpoint
    public var apiEndpoint: String?

    /// Access token
    public var accessToken: String?

    /// Error domain
    public let errorDomain: String? = "com.auroraeditor.models.accounts.gitlab"

    /// Initialize private token configuration
    /// 
    /// - Parameter token: Access token
    /// - Parameter url: API endpoint
    /// 
    /// - Returns: Private token configuration
    public init(_ token: String? = nil, url: String = gitlabBaseURL) {
        apiEndpoint = url
        accessToken = token
    }

    /// Access token field name
    public var accessTokenFieldName: String {
        "private_token"
    }
}
