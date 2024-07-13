//
//  RepositoryModel.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/16.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import Combine
import Version_Control

/// This model handle the fetching and adding of changes etc... for the
public final class RepositoryModel: ObservableObject {

    /// The workspace document
    let workspace: WorkspaceDocument

    /// Whether the git creation sheet is open
    @Published
    var openGitCreationSheet: Bool = false

    /// The repository name
    @Published
    var repositoryName: String = ""

    /// The repository description
    @Published
    var repositoryDescription: String = ""

    /// The repository local path
    @Published
    var repositoryLocalPath: String = ""

    /// Whether to add a README
    @Published
    var addReadme: Bool = false

    /// Whether the workspace is a git repository
    @Published
    var isGitRepository: Bool = false

    // Git repo stuff

    /// The git client
    var gitClient: GitClient?

    /// The repo name
    @Published
    var repoName: String?

    /// The branches
    @Published
    var branches: RepoBranches?

    /// The recent locations
    @Published
    var recentLocations: RepoRecentLocations?

    /// The tags
    @Published
    var tags: RepoTags?

    /// The stashed changes
    @Published
    var stashedChanges: RepoStashedChanges?

    /// The remotes
    @Published
    var remotes: RepoRemotes?

    /// Initialize the model
    /// 
    /// - Parameter workspace: the workspace document
    /// 
    /// - Returns: the model
    init(workspace: WorkspaceDocument) {
        self.workspace = workspace
        self.repositoryLocalPath = workspace.folderURL.path
        self.repositoryName = workspace.folderURL.lastPathComponent
        self.isGitRepository = Check().checkIfProjectIsRepo(workspaceURL: workspace.folderURL)
    }

    /// Add git repo details
    /// 
    /// - Parameter client: the git client
    func addGitRepoDetails(client: GitClient? = nil) {
        if let client = client {
            self.gitClient = client
        }

        self.repoName = workspace.fileSystemClient?.folderURL?.lastPathComponent

        // reponame must not be nil or ""
        guard let repoName = repoName, !repoName.isEmpty else { return }

        let branchNames: [String] = gitClient?.allBranches.map { $0.name } ?? []
        let currentBranchName = (try? gitClient?.getCurrentBranchName()) ?? ""
        let currentBranchIndex = branchNames.firstIndex(of: currentBranchName) ?? -1

        // set branches
        if branches == nil {
            self.branches = RepoBranches(
                contents: branchNames.map { RepoBranch(name: $0) },
                current: currentBranchIndex
            )
        } else {
            // If branches is not nil, update its contents and current index
            self.branches?.contents = branchNames.map { RepoBranch(name: $0) }
            self.branches?.current = currentBranchIndex
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

    /// Watch branches
    var currentBranchNameListener: AnyCancellable?

    /// Watch branch names
    var branchNamesListener: AnyCancellable?

    /// Watch all branch names
    var allBranchNamesListener: AnyCancellable?

    /// Watch branches
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

    /// Deinitializer
    deinit {
        currentBranchNameListener?.cancel()
        branchNamesListener?.cancel()
        allBranchNamesListener?.cancel()
    }
}
