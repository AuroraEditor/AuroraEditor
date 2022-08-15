//
//  IRemote.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/12.
//  Copyright © 2022 Aurora Company. All rights reserved.
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

public var forkedRemotePrefix = "aurora-editor-"

public func forkPullRequestRemoteName(remoteName: String) -> String {
    return "\(forkedRemotePrefix)\(remoteName)"
}

public protocol IRemote {
    var name: String? { get }
    var url: String? { get }
}

public class GitRemote: IRemote {
    public var name: String?
    public var url: String?

    init(name: String? = nil, url: String? = nil) {
        self.name = name
        self.url = url
    }
}
