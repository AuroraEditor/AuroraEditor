//
//  IRemote.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/12.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

public var forkedRemotePrefix = "aurora-editor-"

public func forkPullRequestRemoteName(remoteName: String) -> String {
    return "\(forkedRemotePrefix)\(remoteName)"
}

public protocol IRemote {
    var name: String { get }
    var url: String { get }
}
