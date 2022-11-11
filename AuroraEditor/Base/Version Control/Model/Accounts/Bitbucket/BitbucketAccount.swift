//
//  BitbucketAccount.swift
//  AuroraEditorModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

/// BitBucket base URL
public let bitbucketBaseURL = "https://api.bitbucket.org/2.0"
/// BitBucket web URL
public let bitbucketWebURL = "https://bitbucket.org/"

/// BitBucket Account
public struct BitbucketAccount {
    /// Bitbucket token configuration
    public let configuration: BitbucketTokenConfiguration

    /// Initialize Bitbucket Account
    /// - Parameter config: Bitbucket token configuration
    public init(_ config: BitbucketTokenConfiguration = BitbucketTokenConfiguration()) {
        configuration = config
    }
}

extension Router {
    internal var URLRequest: Foundation.URLRequest? {
        request()
    }
}
