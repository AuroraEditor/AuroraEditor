//
//  [TEMP]DummyClasses.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 18/8/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

// Note to Nanashili: The way I've coded this dummyrepo is so that its as easy as possible to
// migrate to RepositoryModel. You can move the classes starting with `Repo` to the model. They're
// all optionals so you don't need to worry about not having them init'd when you're using the model
// to create a repo.

// TL;DR, just move lines 23-27 to RepositoryModel.

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
        self.branches?.current = current
        self.recentLocations = RepoRecentLocations(contents: recentBranches)
        self.tags = RepoTags(contents: tags)
        self.stashedChanges = RepoStashedChanges(contents: stashedChanges)
        self.remotes = RepoRemotes(contents: remotes)
    }
}
