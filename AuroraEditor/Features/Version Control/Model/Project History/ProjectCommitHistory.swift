//
//  ProjectCommitHistory.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/08.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Version_Control
import OSLog

/// Project Commit History
final class ProjectCommitHistory: Equatable, Identifiable, TabBarItemRepresentable, ObservableObject {
    /// Logger
    let logger = Logger(subsystem: "com.auroraeditor", category: "Project Commit History")

    /// The state of the current Project Commit History View
    enum State {
        case loading, error, success, empty
    }

    /// The state of the current Project Commit History View
    @Published
    var state: State = .loading

    /// The workspace document
    let workspace: WorkspaceDocument

    /// Equatable
    /// 
    /// - Parameter lhs: The left hand side
    /// - Parameter rhs: The right hand side
    /// 
    /// - Returns: Whether the two are equal
    static func == (lhs: ProjectCommitHistory, rhs: ProjectCommitHistory) -> Bool {
        guard lhs.tabID == rhs.tabID else { return false }
        guard lhs.title == rhs.title else { return false }
        return true
    }

    /// The tab ID
    public var tabID: TabBarItemID {
        .projectHistory(workspace.folderURL.lastPathComponent)
    }

    /// The title
    public var title: String {
        workspace.folderURL.lastPathComponent
    }

    /// The icon
    public var icon: Image {
        Image(systemName: "clock")
    }

    /// The icon color
    public var iconColor: Color {
        return .secondary
    }

    /// The project history
    @Published
    var projectHistory: [Commit] = []

    /// The git history date
    @Published
    var gitHistoryDate: CommitDate? {
        didSet {
            DispatchQueue.main.async {
                self.state = .loading
                do {
                    try self.reloadProjectHistory()
                } catch {
                    self.logger.error("Failed to get commits")
                    self.state = .error
                }
            }
        }
    }

    /// Initialize with a workspace document
    /// 
    /// - Parameter workspace: The workspace document
    /// 
    /// - Returns: A Project Commit History instance
    init(workspace: WorkspaceDocument) {
        self.workspace = workspace
        loadProjectHistory()
    }

    /// Load the project history
    private func loadProjectHistory() {
        DispatchQueue.main.async {
            self.state = .loading
        }

        do {
            try reloadProjectHistory()
        } catch {
            logger.error("Failed to get commits: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.state = .error
            }
        }
    }

    /// Reload the project history
    /// 
    /// - Throws: Error
    func reloadProjectHistory() throws {
        var additionalArgs: [String] = []

        if let historyDate = gitHistoryDate {
            additionalArgs = historyDate.gitArgs
        }

        let projectHistory = try GitLog().getCommits(directoryURL: workspace.folderURL,
                                                     revisionRange: nil,
                                                     limit: 150,
                                                     skip: 0,
                                                     additionalArgs: additionalArgs)

        DispatchQueue.main.async {
            self.projectHistory = projectHistory
            self.state = projectHistory.isEmpty ? .empty : .success
        }
    }
}
