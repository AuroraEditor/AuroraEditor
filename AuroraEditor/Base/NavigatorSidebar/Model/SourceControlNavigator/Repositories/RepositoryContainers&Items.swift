//
//  RepositoryContainers&Items.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 18/8/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

// MARK: Repo Containers

class RepoContainer {
    var contents: [Any]
    init(contents: [Any]) {
        self.contents = contents
    }
}

class RepoBranches: RepoContainer {
    var current: Int

    init(contents: [RepoBranch], current: Int = 0) {
        self.current = current
        super.init(contents: contents)
    }
}

class RepoRecentLocations: RepoContainer {
    init(contents: [RepoBranch]) {
        super.init(contents: contents)
    }
}

class RepoTags: RepoContainer {
    init(contents: [RepoTag]) {
        super.init(contents: contents)
    }
}

class RepoStashedChanges: RepoContainer {
    init(contents: [RepoChange]) {
        super.init(contents: contents)
    }
}

class RepoRemotes: RepoContainer {
    init(contents: [RepoRemote]) {
        super.init(contents: contents)
    }
}

class RepoRemote: RepoContainer {
    var name: String

    init(content: [RepoBranch], name: String) {
        self.name = name
        super.init(contents: content)
    }
}

// MARK: Repo items

class RepoItem {
    var name: String

    init(name: String) {
        self.name = name
    }
}

class RepoBranch: RepoItem {}
class RepoTag: RepoItem {}
class RepoChange: RepoItem {}
