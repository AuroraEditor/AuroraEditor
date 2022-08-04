//
//  GitlabConfiguration.swift
//  AuroraEditorModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

public struct GitlabTokenConfiguration: GitConfiguration {

    public var apiEndpoint: String?
    public var accessToken: String?
    public let errorDomain: String? = "com.auroraeditor.models.accounts.gitlab"

    public init(_ token: String? = nil, url: String = gitlabBaseURL) {
        apiEndpoint = url
        accessToken = token
    }
}

public struct PrivateTokenConfiguration: GitConfiguration {
    public var apiEndpoint: String?
    public var accessToken: String?
    public let errorDomain: String? = "com.auroraeditor.models.accounts.gitlab"

    public init(_ token: String? = nil, url: String = gitlabBaseURL) {
        apiEndpoint = url
        accessToken = token
    }

    public var accessTokenFieldName: String {
        "private_token"
    }
}
