//
//  RepositoryModel.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/16.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

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

    func addGitRepoDetails(client: GitClient) {
        self.gitClient = client

        self.repoName = workspace.workspaceClient?.folderURL?.lastPathComponent

        // reponame must not be nil or ""
        guard repoName != nil && !repoName!.isEmpty else { return }

        let branchNames: [String] = ((try? gitClient?.getBranches(false)) ?? [])

        // set branches
        self.branches = RepoBranches(contents: branchNames.map { branch in
             RepoBranch(name: branch)
        })

        // TODO: Get recent locations
        self.recentLocations = RepoRecentLocations(contents: [])
        // TODO: Get tags
        self.tags = RepoTags(contents: [])
        // TODO: Get stashed changes
        self.stashedChanges = RepoStashedChanges(contents: [])

        // TODO: Get remote repo branches
        remotes = RepoRemotes(contents: [
            RepoRemote(content: [], name: "Origin")
        ])
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
