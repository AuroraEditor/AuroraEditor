//
//  HistoryInspectorModel.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/18.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import Version_Control

/// The model for the History Inspector
public final class HistoryInspectorModel: ObservableObject {

    /// The state of the current History Inspector View
    enum State {
        /// Loading
        case loading

        /// Error
        case error

        /// Success
        case success
    }

    /// The current state of the History Inspector
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
    public var commitHistory: [CommitHistory]

    /// Initialize with a GitClient
    /// 
    /// - Parameter workspaceURL: the current workspace URL
    /// - Parameter fileURL: the current file URL
    ///
    /// - Returns: a new HistoryInspectorModel instance
    public init(workspaceURL: URL, fileURL: String) {
        self.workspaceURL = workspaceURL
        self.fileURL = fileURL
        gitClient = GitClient(
            directoryURL: workspaceURL,
            shellClient: sharedShellClient.shellClient
        )
        do {
            let commitHistory = try gitClient.getCommitHistory(entries: 40, fileLocalPath: fileURL)
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
