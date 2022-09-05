//
//  RepositoryModel.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/16.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation
import Combine

public final class RepositoryModel: ObservableObject {

    let workspace: WorkspaceDocument

    @Published
    var openGitCreationSheet: Bool = false

    @Published
    var repositoryName: String = ""

    @Published
    var repositoryDescription: String = ""

    @Published
    var repositoryLocalPath: String = ""

    @Published
    var addReadme: Bool = false

    @Published
    var isGitRepository: Bool = false

    // Git repo stuff
    var gitClient: GitClient?
    @Published
    var repoName: String?
    @Published
    var branches: RepoBranches?
    @Published
    var recentLocations: RepoRecentLocations?
    @Published
    var tags: RepoTags?
    @Published
    var stashedChanges: RepoStashedChanges?
    @Published
    var remotes: RepoRemotes?

    init(workspace: WorkspaceDocument) {
        self.workspace = workspace
        guard let projectPath = workspace.workspaceClient?.folderURL else { return }
        self.repositoryLocalPath = projectPath.path
        self.repositoryName = projectPath.lastPathComponent
        self.isGitRepository = checkIfProjectIsRepo()
    }

    func addGitRepoDetails(client: GitClient? = nil) {
        if let client = client {
            self.gitClient = client
        }

        self.repoName = workspace.workspaceClient?.folderURL?.lastPathComponent

        // reponame must not be nil or ""
        guard repoName != nil && !repoName!.isEmpty else { return }

        let branchNames: [String] = ((try? gitClient?.getBranches(allBranches: false)) ?? [])
        let currentBranchName = (try? gitClient?.getCurrentBranchName()) ?? ""
        let currentBranchIndex = branchNames.firstIndex(of: currentBranchName) ?? -1

        // set branches
        if branches == nil {
            self.branches = RepoBranches(contents: branchNames.map { branch in
                RepoBranch(name: branch)
            }, current: currentBranchIndex)
        } else {
            branches?.contents = branchNames.map { RepoBranch(name: $0) }
            branches?.current = currentBranchIndex
        }

        // TODO: Get recent locations
        if recentLocations == nil {
            self.recentLocations = RepoRecentLocations(contents: [])
        } else {
            recentLocations?.contents = []
        }
        // TODO: Get tags
        if tags == nil {
            self.tags = RepoTags(contents: [])
        } else {
            tags?.contents = []
        }
        // TODO: Get stashed changes
        if stashedChanges == nil {
            self.stashedChanges = RepoStashedChanges(contents: [])
        } else {
            stashedChanges?.contents = []
        }

        // TODO: Get remote repo branches
        remotes = RepoRemotes(contents: [
            RepoRemote(content: [], name: "Origin")
        ])

        watchBranches()
    }

    var currentBranchNameListener: AnyCancellable?
    var branchNamesListener: AnyCancellable?
    var allBranchNamesListener: AnyCancellable?
    func watchBranches() {
        currentBranchNameListener = gitClient?.currentBranchName.sink(receiveValue: { newName in
            guard let branches = self.branches, let branchContents = branches.contents as? [RepoBranch] else { return }
            branches.current = branchContents.firstIndex(where: { $0.name == newName }) ?? -1
        })

        branchNamesListener = gitClient?.branchNames.sink(receiveValue: { newBranchNames in
            guard let branches = self.branches else { return }
            branches.contents = newBranchNames.map({ branchName in
                RepoBranch(name: branchName)
            })
        })

        allBranchNamesListener = gitClient?.allBranchNames.sink(receiveValue: { newBranchNames in
            guard let remotes = self.remotes, let remoteContents = remotes.contents as? [RepoRemote] else { return }
            let newBranches = newBranchNames.map({ branchName in
                RepoBranch(name: branchName)
            })
            for remote in remoteContents {
                remote.contents = newBranches
            }
        })
    }

    deinit {
        currentBranchNameListener?.cancel()
        branchNamesListener?.cancel()
        allBranchNamesListener?.cancel()
    }

    func checkIfProjectIsRepo() -> Bool {
        guard let path = workspace.workspaceClient?.folderURL else {
            return false
        }

        do {
            let type = try getRepositoryType(path: path.path)

            if type == .unsafe {
                // If the path is considered unsafe by Git we won't be able to
                // verify that it's a repository (or worktree). So we'll fall back to this
                // naive approximation.
                Log.debug(type)
                return FileManager().directoryExistsAtPath("\(path)/.git")
            }

            return type != .missing
        } catch {
            Log.error("We couldn't verify if the current project is a git repo!")
            return false
        }
    }
}
