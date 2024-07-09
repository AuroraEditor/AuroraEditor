//
//  BranchCommitHistory.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/10.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Version_Control
import OSLog

@available(*,
            deprecated,
            renamed: "VersionControl",
            message: "This will be deprecated in favor of the new VersionControl Remote SDK APIs.")/// Branch Commit History
final class BranchCommitHistory: Equatable, Identifiable, TabBarItemRepresentable, ObservableObject {

    /// The state of the current Branch Commit History View
    enum State {

        /// Loading
        case loading

        /// Error
        case error

        /// Success
        case success

        /// Empty
        case empty
    }

    /// The state of the current Branch Commit History View
    @Published
    var state: State = .loading

    /// The workspace document
    let workspace: WorkspaceDocument

    /// The branch name
    let branchName: String

    /// Logger
    let logger = Logger(subsystem: "com.auroraeditor.vcs", category: "Branch commit history")

    /// Equatable
    /// 
    /// - Parameter lhs: The left hand side
    /// - Parameter rhs: The right hand side
    /// 
    /// - Returns: Whether the two are equal
    static func == (lhs: BranchCommitHistory, rhs: BranchCommitHistory) -> Bool {
        guard lhs.tabID == rhs.tabID else { return false }
        guard lhs.title == rhs.title else { return false }
        return true
    }

    /// The tab ID
    public var tabID: TabBarItemID {
        .branchHistory(branchName)
    }

    /// The title
    public var title: String {
        branchName
    }

    /// The icon
    public var icon: Image {
        Image("git.branch")
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
                }
            }
        }
    }

    /// Initialize with a workspace and branch name
    /// 
    /// - Parameter workspace: The workspace
    /// - Parameter branchName: The branch name
    /// 
    /// - Returns: A Branch Commit History
    init(workspace: WorkspaceDocument, branchName: String) {
        self.workspace = workspace
        self.branchName = branchName

        DispatchQueue.main.async {
            self.state = .loading
        }

        DispatchQueue.main.async {
            do {
                try self.reloadProjectHistory()
            } catch {
                DispatchQueue.main.async {
                    self.state = .empty
                }

                self.projectHistory = []
            }
        }
    }

    /// Reload the project history
    /// 
    /// - Throws: Error
    func reloadProjectHistory() throws {

        var additionArgs: [String] = []
//
//        if gitHistoryDate != nil {
//            switch gitHistoryDate {
//            case .lastDay:
//                additionArgs.append("--since=\"24 hours ago\"")
//            case .lastSevenDays:
//                additionArgs.append("--since=\"7 days ago\"")
//            case .lastThirtyDays:
//                additionArgs.append("--since=\"30 days ago\"")
//            case .none:
//                additionArgs = []
//            }
//        }

        let projectHistory = try GitLog().getCommits(directoryURL: workspace.workspaceURL(),
                                                     revisionRange: branchName,
                                                     limit: 150,
                                                     skip: 0,
                                                     additionalArgs: additionArgs)
        if projectHistory.isEmpty {
            DispatchQueue.main.async {
                self.state = .empty
            }
        } else {
            DispatchQueue.main.async {
                self.state = .success
            }
        }

        self.projectHistory = projectHistory
    }
}
