//
//  GitUIModel.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/07/13.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// A Git UI Model
public final class GitUIModel: ObservableObject {
    /// A GitClient instance
    private(set) var gitClient: GitClient

    /// The base URL of the workspace
    private(set) var workspaceURL: URL

    /// Initialize with a GitClient
    /// 
    /// - Parameter workspaceURL: the current workspace URL
    ///
    /// - Returns: a GitUIModel instance
    public init(workspaceURL: URL) {
        self.workspaceURL = workspaceURL
        gitClient = GitClient(
            directoryURL: workspaceURL,
            shellClient: .live()
        )
    }

    /// Stage changes
    /// 
    /// - Parameter message: the stash message
    public func stashChanges(message: String?) {
        do {
            try gitClient.stashChanges(message: message ?? "")
        } catch {
            Log.fault("Failed to stash changes!")
        }
    }
}
