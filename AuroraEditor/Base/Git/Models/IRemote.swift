//
//  IRemote.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/12.
//  Copyright © 2022 Aurora Company. All rights reserved.
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

/// forked remote prefix
public var forkedRemotePrefix = "aurora-editor-"

/// Fork pull request remote name generator
/// - Parameter remoteName: Name
/// - Returns: Prefix+remote name
public func forkPullRequestRemoteName(remoteName: String) -> String {
    return "\(forkedRemotePrefix)\(remoteName)"
}

/// IRemote
public protocol IRemote {
    /// Name
    var name: String { get }
    /// URL
    var url: String { get }
}

public class GitRemote: IRemote {
    public var name: String
    public var url: String

    init(name: String, url: String) {
        self.name = name
        self.url = url
    }
}
