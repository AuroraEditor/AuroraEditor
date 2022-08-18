//
//  [TEMP]DummyClasses.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 18/8/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

// TODO: Nanashili (issued by Kai Tay): Remove dummy classes for repo and branch, replace with actual data
class DummyRepo {
    var repoName: String

    var branches: DummyBranches?
    var recentLocations: DummyRecentLocations?
    var tags: DummyTags?
    var stashedChanges: DummyStashedChanges?
    var remotes: DummyRemotes?

    init(repoName: String,
         branches: [DummyBranch],
         recentBranches: [DummyBranch] = [],
         tags: [DummyTag] = [],
         stashedChanges: [DummyChange] = [],
         current: Int = 0,
         remotes: [DummyRemote] = [],
         isLocal: Bool = true
    ) {
        self.repoName = repoName
        self.branches = DummyBranches(contents: branches, current: current)
        self.recentLocations = DummyRecentLocations(contents: recentBranches)
        self.tags = DummyTags(contents: tags)
        self.stashedChanges = DummyStashedChanges(contents: stashedChanges)
        self.remotes = DummyRemotes(contents: remotes)
    }
}

// MARK: Dummy Containers

class DummyContainer {
    var contents: [Any]
    init(contents: [Any]) {
        self.contents = contents
    }
}

class DummyBranches: DummyContainer {
    var current: Int

    init(contents: [DummyBranch], current: Int = 0) {
        self.current = current
        super.init(contents: contents)
    }
}

class DummyRecentLocations: DummyContainer {
    init(contents: [DummyBranch]) {
        super.init(contents: contents)
    }
}

class DummyTags: DummyContainer {
    init(contents: [DummyTag]) {
        super.init(contents: contents)
    }
}

class DummyStashedChanges: DummyContainer {
    init(contents: [DummyChange]) {
        super.init(contents: contents)
    }
}

class DummyRemotes: DummyContainer {
    init(contents: [DummyRemote]) {
        super.init(contents: contents)
    }
}

class DummyRemote: DummyContainer {
    var name: String

    init(content: [DummyBranch], name: String) {
        self.name = name
        super.init(contents: content)
    }
}

// MARK: Dummy items

class DummyItem {
    var name: String

    init(name: String) {
        self.name = name
    }
}

class DummyBranch: DummyItem {}
class DummyTag: DummyItem {}
class DummyChange: DummyItem {}
