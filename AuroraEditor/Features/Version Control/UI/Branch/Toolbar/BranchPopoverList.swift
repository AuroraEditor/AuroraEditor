//
//  BranchPopoverList.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/07.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import SwiftUI
import Version_Control

/// A popover view that appears once the branch picker is tapped.
struct BranchPopoverList: View {
    // MARK: - Properties

    @EnvironmentObject
    var versionControl: VersionControlModel

    @ObservedObject
    var workspace: WorkspaceDocument

    /// The current branch.
    @State
    var currentBranch: GitBranch?

    // MARK: - Body

    /// The view body.
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if currentBranch != nil {
                    headerLabel("Current Branch")
                    BranchCell(
                        handleRefresh: {
                            Task {
                                await versionControl.getWorkspaceBranches()
                            }
                        },
                        workspace: workspace,
                        branch: versionControl.currentBranchObject ?? GitBranch(
                            name: "Unknown Branch",
                            type: .local,
                            ref: ""
                        )
                    )
                }
                if !recentBranchNames.isEmpty {
                    headerLabel("Recent Branches")
                    ForEach(recentBranchNames, id: \.self) { branch in
                        BranchCell(
                            handleRefresh: {
                                Task {
                                    await versionControl.getWorkspaceBranches()
                                }
                            },
                            workspace: workspace,
                            branch: branch
                        )
                    }
                }
                if !otherBranchNames.isEmpty {
                    headerLabel("Other Branches")
                    ForEach(otherBranchNames, id: \.self) { branch in
                        BranchCell(
                            handleRefresh: {
                                Task {
                                    await versionControl.getWorkspaceBranches()
                                }
                            },
                            workspace: workspace,
                            branch: branch
                        )
                    }
                }
            }
            .padding(.top, 10)
            .padding(5)
        }
        .frame(
            minWidth: 340,
            maxWidth: 340,
            maxHeight: 700
        )
    }

    /// A header label.
    func headerLabel(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.bold())
            .foregroundColor(.secondary)
            .padding(.horizontal)
            .padding(.vertical, 5)
    }

    /// A collection of branch names that are not the current branch and not recently accessed branches.
    var otherBranchNames: [GitBranch] {
        let recentBranchNamesSet = Set(recentBranchNames.map { $0.name })
        return versionControl.workspaceBranches
            .filter { branch in
                branch.name != currentBranch?.name && !recentBranchNamesSet.contains(branch.name)
            }
            .sorted { branch1, branch2 in
                let date1 = branch1.tip?.author.date
                let date2 = branch2.tip?.author.date

                switch (date1, date2) {
                case (.some(let d1), .some(let d2)):
                    return d1 > d2
                default:
                    return false
                }
            }
    }

    /// A collection of recently accessed branch names, limited to the five most recent branches.
    var recentBranchNames: [GitBranch] {
        let recentBranchNameStrings = versionControl.workspaceRecentBranches
        let recentBranchNameSet = Set(recentBranchNameStrings)
        return versionControl.workspaceBranches.compactMap { branch in
            if recentBranchNameSet.contains(branch.name) && branch.name != currentBranch?.name {
                return branch
            }
            return nil
        }
    }
}
