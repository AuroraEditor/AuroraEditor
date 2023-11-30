//
//  BranchCommitHistory.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/10.
//  Copyright © 2023 Aurora Company. All rights reserved.
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
    var projectHistory: [Commit] = []

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

        var additionArgs: [String] = []

        if gitHistoryDate != nil {
            switch gitHistoryDate {
            case .lastDay:
                additionArgs.append("--since=\"24 hours ago\"")
            case .lastSevenDays:
                additionArgs.append("--since=\"7 days ago\"")
            case .lastThirtyDays:
                additionArgs.append("--since=\"30 days ago\"")
            case .none:
                additionArgs = []
            }
        }

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
