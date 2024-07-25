//
//  BranchCell.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/06.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import SwiftUI
import Version_Control

/// A Button Cell that represents a branch in the branch picker
struct BranchCell: View {

    /// The dismiss environment.
    @Environment(\.dismiss)
    private var dismiss

    var handleRefresh: () -> Void

    @State
    var branch: GitBranch

    @EnvironmentObject
    private var versionControl: VersionControlModel

    @ObservedObject
    private var workspace: WorkspaceDocument

    /// The hover state.
    @State
    private var isHovering: Bool = false

    init(
        handleRefresh: @escaping () -> Void,
        workspace: WorkspaceDocument,
        branch: GitBranch
    ) {
        self.handleRefresh = handleRefresh
        self.workspace = workspace
        self.branch = branch
    }

    /// The view body.
    var body: some View {
        HStack {
            Button {
                do {
                    try GitCheckout().checkoutBranch(directoryURL: workspace.folderURL,
                                                     account: nil,
                                                     branch: branch,
                                                     progressCallback: nil)
                } catch {
                    print("Failed to checkout branch")
                }
                dismiss()
            } label: {
                HStack {
                    Label {
                        HStack(alignment: .center) {
                            VStack(alignment: .leading) {
                                Text(branch.name)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                getBranchCommitInfo()
                                    .font(.system(size: 12))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    } icon: {
                        Image("git.branch")
                            .imageScale(.large)
                            .accessibilityLabel(Text("Git Branch"))
                    }
                    .foregroundColor(isHovering ? .white : .secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isHovering {
                branchMenu()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(
            EffectView.selectionBackground(isHovering)
        )
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .onHover { active in
            isHovering = active
        }
    }

    private func branchMenu() -> some View {
        Menu {
            Button(action: {
                workspace.data.currentBranch = branch
                workspace.data.showRenameBranchSheet.toggle()
            }) {
                Text("Rename \"\(branch.name)\"...")
            }
            .disabled(branch.type == .remote ? true : false)
            Button(action: {
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString(branch.name, forType: .string)
            }) {
                Text("Copy Branch Name")
            }
            Divider()
            Button(action: {
                workspace.data.branchRevision = branch.name
                workspace.data.showBranchCreationSheet.toggle()
            }) {
                Text("New Branch from \"\(branch.name)\"...")
            }
            Divider()
            Button(action: {
                do {
                    if branch.type == .remote {
                        if branch.name.contains("/") {
                            let parts = branch.name.split(separator: "/", maxSplits: 1)
                            if try Branch().deleteRemoteBranch(directoryURL: workspace.folderURL,
                                                               remoteName: String(parts[0]),
                                                               remoteBranchName: String(parts[1])) {
                                handleRefresh()
                            }
                        }
                    } else if branch.type == .local {
                        if try Branch().deleteLocalBranch(directoryURL: workspace.folderURL,
                                                          branchName: branch.name) {
                            handleRefresh()
                        }
                    }
                } catch {
                    return
                }
            }) {
                Text("Delete Branch")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.system(size: 16))
                .foregroundColor(.white)
                .accessibilityLabel(Text("Branch Menu"))
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
    }

    private func getBranchCommitInfo() -> Text {
        guard let commit = branch.tip else {
            return Text("")
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .long

        let formattedDate = formatter.string(from: commit.author.date)
        let authorName = Text(commit.author.name).bold()
        let commitInfo = Text(" committed on \(formattedDate)")

        return authorName + commitInfo
    }
}
