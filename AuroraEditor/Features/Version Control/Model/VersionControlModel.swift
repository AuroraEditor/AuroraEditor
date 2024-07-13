//
//  VersionControlModel.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/08.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation
import Combine
import Version_Control

/// A model class responsible for handling version control operations within the Aurora Editor workspace.
class VersionControlModel: ObservableObject {

    /// Shared singleton instance of `VersionControlModel`.
    public static let shared: VersionControlModel = .init()

    /// The workspace document associated with the version control model.
    private var workspaceURL: URL?

    /// Indicates whether the workspace is a Git repository.
    @Published var workspaceIsRepository: Bool = false

    /// The current branch of the workspace.
    @Published var currentWorkspaceBranch: String = ""

    /// The list of branches in the workspace.
    @Published var workspaceBranches: [GitBranch] = []

    /// The list of tags in the workspace.
    @Published var workspaceTags: [String] = []

    /// The list of remote repositories in the workspace.
    @Published var workspaceRemotes: [String] = []

    /// The list of recent branches in the workspace.
    @Published var workspaceRecentBranches: [String] = []

    /// The URL of the upstream remote repository.
    @Published var upstreamURL: String = ""

    /// The list of files changed in the upstream remote repository.
    @Published var changedUpstreamFiles: [String] = []

    /// A set of cancellable objects for Combine publishers.
    private var cancellables = Set<AnyCancellable>()

    private let check: Check = Check()
    private let branch: Branch = Branch()
    private let reflog: Reflog = Reflog()
    private let remote: Remote = Remote()
    private let revParse: RevParse = RevParse()
    private let log: GitLog = GitLog()

    /// Private initializer to enforce singleton pattern.
    private init() {}

    /// Initializes the version control model with the provided workspace.
    ///
    /// - Parameter workspace: The workspace document to initialize the model with.
    public func initializeModel(workspaceURL: URL) {
        self.workspaceURL = workspaceURL
        checkIfWorkspaceIsRepository()

        Task {
            await getWorkspaceBranches()
            await getWorkspaceRecentBranches()
            await getRemoteURL()
            await getRemoteChangeFiles()
        }
    }

    /// Checks if the current workspace is a Git repository.
    ///
    /// This function sets the `workspaceIsRepository` property based on whether the current workspace is a Git repository.
    public func checkIfWorkspaceIsRepository() {
        guard let workspaceURL = workspaceURL else { return }

        DispatchQueue.main.async {
            self.workspaceIsRepository = self.check.checkIfProjectIsRepo(
                workspaceURL: workspaceURL
            )
        }
    }

    /// Retrieves the branches of the current workspace asynchronously.
    ///
    /// This function fetches the list of branches in the workspace and sets the `workspaceBranches` and `currentWorkspaceBranch` properties.
    public func getWorkspaceBranches() async {
        guard let workspaceURL = workspaceURL else { return }

        do {
            let branches = try await self.branch.getBranches(
                directoryURL: workspaceURL
            )
            let currentBranch = try await self.branch.getCurrentBranch(
                directoryURL: workspaceURL
            )

            DispatchQueue.main.async {
                self.workspaceBranches = branches
                self.currentWorkspaceBranch = currentBranch
            }
        } catch {
            DispatchQueue.main.async {
                self.workspaceBranches = []
                self.currentWorkspaceBranch = "Unknown Branch"
            }
        }
    }

    /// Retrieves the recent branches of the current workspace asynchronously.
    ///
    /// This function fetches the list of recent branches in the workspace and sets the `workspaceRecentBranches` property.
    public func getWorkspaceRecentBranches() async {
        guard let workspaceURL = workspaceURL else { return }

        do {
            let recentBranchNameStrings = try await self.reflog.getRecentBranches(
                directoryURL: workspaceURL,
                limit: 5
            )
            DispatchQueue.main.async {
                self.workspaceRecentBranches = recentBranchNameStrings
            }
        } catch {
            DispatchQueue.main.async {
                self.workspaceRecentBranches = []
            }
        }
    }

    /// Retrieves the remote URL of the upstream repository asynchronously.
    ///
    /// This function fetches the URL of the upstream remote repository and sets the `upstreamURL` property.
    public func getRemoteURL() async {
        guard let workspaceURL = workspaceURL else { return }

        do {
            var remoteURL = try await self.remote.getRemoteURL(
                directoryURL: workspaceURL,
                name: "upstream"
            )

            if remoteURL == nil {
                remoteURL = try await self.remote.getRemoteURL(
                    directoryURL: workspaceURL,
                    name: "origin"
                )
            }

            DispatchQueue.main.async {
                self.upstreamURL = remoteURL?.removingNewLines() ?? ""
            }
        } catch {
            DispatchQueue.main.async {
                self.upstreamURL = ""
            }
        }
    }

    /// The current branch object of the workspace.
    ///
    /// This computed property returns the current branch object from the list of workspace branches.
    public var currentBranchObject: GitBranch? {
        return workspaceBranches.first { $0.name == currentWorkspaceBranch }
    }

    /// Retrieves the list of files changed in the latest commit of the upstream remote repository asynchronously.
    ///
    /// This function fetches the latest commit hash of the local and upstream repositories. If the local repository
    /// is up to date with the upstream repository, it does not fetch the changed files. Otherwise, it retrieves the list
    /// of files changed in the latest commit of the upstream repository and sets the `changedUpstreamFiles` property.
    ///
    /// - Throws: An error if there is a problem accessing the Git repository or executing the Git commands.
    public func getRemoteChangeFiles() async {
        guard let workspaceURL = workspaceURL else {
            return
        }

        do {
            let currentLocalSha = try self.revParse.getLatestCommitHash(
                directoryURL: workspaceURL
            )

            let upstreamLatestSha = try await self.remote.getLatestCommitHashAndRef(
                directoryURL: workspaceURL,
                repoURL: upstreamURL,
                branch: currentWorkspaceBranch
            )

            // If the local commit is up to date, do not fetch changed files of the upstream repo.
            if currentLocalSha == upstreamLatestSha.commitHash {
                return
            }

            let changedFiles = try await self.log.getChangedFilesBetweenRefs(
                directoryURL: workspaceURL,
                currentSha: currentLocalSha,
                sha: upstreamLatestSha.commitHash
            )

            DispatchQueue.main.async {
                self.changedUpstreamFiles = changedFiles
            }
        } catch {
            DispatchQueue.main.async {
                self.changedUpstreamFiles = []
            }
        }
    }
}
