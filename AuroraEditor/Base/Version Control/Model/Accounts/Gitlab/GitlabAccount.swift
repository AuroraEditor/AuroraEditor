//
//  GitlabAccount.swift
//  AuroraEditorModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

/// Gitlab Base URL
public let gitlabBaseURL = "https://gitlab.com/api/v4/"

/// Gitlab Web URL
public let gitlabWebURL = "https://gitlab.com/"

public struct GitlabAccount {
    /// GIT Configuration
    public let configuration: GitConfiguration

    /// Initialize Gitlab cccount
    /// - Parameter config: GIT Configuration
    public init(_ config: GitConfiguration = GitlabTokenConfiguration()) {
        configuration = config
    }
}
