//
//  GithubAccount.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// GitHub Base URL
public let githubBaseURL = "https://api.github.com"

/// GitHub Web URL
public let githubWebURL = "https://github.com"

/// GitHub Account
public struct GithubAccount {
    /// GIT Configuration
    public let configuration: GithubTokenConfiguration

    /// Initialize GitHub Account
    /// - Parameter config: GitHub Configuration
    public init(_ config: GithubTokenConfiguration = GithubTokenConfiguration()) {
        configuration = config
    }
}
