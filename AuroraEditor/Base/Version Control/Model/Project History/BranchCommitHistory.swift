//
//  BranchCommitHistory.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/10.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI
import Version_Control

final class BranchCommitHistory: Equatable, Identifiable, TabBarItemRepresentable, ObservableObject {

    /// The state of the current Branch Commit History View
    enum State {
        case loading
        case error
        case success
        case empty
    }

    @Published
    var state: State = .loading

    let workspace: WorkspaceDocument

    let branchName: String

    static func == (lhs: BranchCommitHistory, rhs: BranchCommitHistory) -> Bool {
        guard lhs.tabID == rhs.tabID else { return false }
        guard lhs.title == rhs.title else { return false }
        return true
    }

    public var tabID: TabBarItemID {
        .branchHistory(branchName)
    }

    public var title: String {
        branchName
    }

    public var icon: Image {
        Image("git.branch")
    }

    public var iconColor: Color {
        return .secondary
    }

    @Published
    var projectHistory: [CommitHistory] = []

    @Published
    var gitHistoryDate: CommitDate? {
        didSet {
            DispatchQueue.main.async {
                self.state = .loading
                do {
                    try self.reloadProjectHistory()
                } catch {
                    Log.error("Failed to get commits")
                }
            }
        }
    }

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

    func reloadProjectHistory() throws {
        let projectHistory = try getCommits(directoryURL: workspace.workspaceURL(),
                                            revisionRange: branchName,
                                            limit: 150,
                                            commitsSince: gitHistoryDate)
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
