//
//  IRemote.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/12.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

public var ForkedRemotePrefix = "aurora-editor-"

public func forkPullRequestRemoteName(remoteName: String) -> String {
    return "\(ForkedRemotePrefix)\(remoteName)"
}

public protocol IRemote {
    var name: String { get }
    var url: String { get }
}

//public func remoteEquals(x: IRemote? = nil, y: IRemote? = nil) -> Bool {
//    if x == nil || y == nil {
//        return false
//    }
//
//    return x.name == y.name && x.url == y.url
//}
