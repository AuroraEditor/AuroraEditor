//
//  [TEMP]DummyClasses.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 18/8/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

// TODO: Nanashili (issued by Kai Tay): Implement the DummyRepo properties into RepositoryModel
// The rest of the classes can stay the same.
class DummyRepo {
    var repoName: String

    var branches: RepoBranches?
    var recentLocations: RepoRecentLocations?
    var tags: RepoTags?
    var stashedChanges: RepoStashedChanges?
    var remotes: RepoRemotes?

    init(repoName: String,
         branches: [RepoBranch],
         recentBranches: [RepoBranch] = [],
         tags: [RepoTag] = [],
         stashedChanges: [RepoChange] = [],
         current: Int = 0,
         remotes: [RepoRemote] = [],
         isLocal: Bool = true
    ) {
        self.repoName = repoName
        self.branches = RepoBranches(contents: branches, current: current)
        self.recentLocations = RepoRecentLocations(contents: recentBranches)
        self.tags = RepoTags(contents: tags)
        self.stashedChanges = RepoStashedChanges(contents: stashedChanges)
        self.remotes = RepoRemotes(contents: remotes)
    }
}
