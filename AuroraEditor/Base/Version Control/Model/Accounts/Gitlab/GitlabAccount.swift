//
//  GitlabAccount.swift
//  AuroraEditorModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

// TODO: DOCS (Nanashi Li)
public let gitlabBaseURL = "https://gitlab.com/api/v4/"
public let gitlabWebURL = "https://gitlab.com/"

public struct GitlabAccount {
    public let configuration: GitConfiguration

    public init(_ config: GitConfiguration = GitlabTokenConfiguration()) {
        configuration = config
    }
}
