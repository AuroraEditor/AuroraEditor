//
//  WorkspaceUtils.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/09.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

/// A utility class that provides setup and cleanup functionality for
/// monitoring version control in a workspace.
class WorkspaceUtils {

    /// The workspace document being managed.
    private let workspace: WorkspaceDocument

    /// The version control monitor for the workspace.
    private var versionControlMonitor: VersionControlMonitor?

    /// Initializes a new instance of `WorkspaceUtils` with the specified workspace document.
    /// - Parameter workspace: The workspace document to manage.
    init(workspace: WorkspaceDocument) {
        self.workspace = workspace
    }

    /// Sets up the version control monitor for the workspace.
    ///
    /// This method initializes the `VersionControlMonitor` with the workspace's folder URL
    /// and starts monitoring the Git directory for changes.
    @MainActor
    func setupVersionControlMonitor() {
        versionControlMonitor = VersionControlMonitor(workspaceURL: workspace.folderURL)
        versionControlMonitor?.startMonitoringGitDirectory()
    }

    /// Cleans up the version control monitor for the workspace.
    ///
    /// This method stops monitoring the Git directory and deallocates the `VersionControlMonitor` instance.
    func cleanupVersionControlMonitor() {
        versionControlMonitor?.stopMonitoringGitDirectory()
        versionControlMonitor = nil
    }
}
