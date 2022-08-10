//
//  HistoryInspectorModel.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/04/18.
//

import Foundation

public final class HistoryInspectorModel: ObservableObject {

    /// The state of the current History Inspector View
    enum State {
        case loading
        case error
        case success
    }

    @Published
    var state: State = .loading

    /// A GitClient instance
    private(set) var gitClient: GitClient

    /// The base URL of the workspace
    private(set) var workspaceURL: URL

    /// The base URL of the workspace
    private(set) var fileURL: String

    /// The selected branch from the GitClient
    @Published
    public var commitHistory: [Commit]

    /// Initialize with a GitClient
    /// - Parameter workspaceURL: the current workspace URL
    ///
    public init(workspaceURL: URL, fileURL: String) {
        self.workspaceURL = workspaceURL
        self.fileURL = fileURL
        gitClient = GitClient.default(
            directoryURL: workspaceURL,
            shellClient: sharedShellClient.shellClient
        )
        do {
            let commitHistory = try gitClient.getCommitHistory(40, fileURL)
            self.commitHistory = commitHistory

            DispatchQueue.main.async {
                self.state = .success
            }
        } catch {
            commitHistory = []

            DispatchQueue.main.async {
                self.state = .success
            }
        }
    }
}
