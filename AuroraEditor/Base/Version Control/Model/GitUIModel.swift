//
//  GitUIModel.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/07/13.
//

import Foundation

public final class GitUIModel: ObservableObject {
    /// A GitClient instance
    private(set) var gitClient: GitClient

    /// The base URL of the workspace
    private(set) var workspaceURL: URL

    /// Initialize with a GitClient
    /// - Parameter workspaceURL: the current workspace URL
    ///
    public init(workspaceURL: URL) {
        self.workspaceURL = workspaceURL
        gitClient = GitClient(
            directoryURL: workspaceURL,
            shellClient: .live()
        )
    }

    public func stashChanges(message: String?) {
        do {
            try gitClient.stashChanges(message: message ?? "")
        } catch {
            Log.error("Failed to stash changes!")
        }
    }
}
