//
//  ToolbarBranchPicker.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 21.04.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Combine

/// A view that pops up a branch picker.
public struct ToolbarBranchPicker: View {

    /// The active state of the control.
    @Environment(\.controlActiveState)
    private var controlActive

    /// The file system client.
    private var fileSystemClient: FileSystemClient?

    /// The hover state.
    @State
    private var isHovering: Bool = false

    /// The display popover state.
    @State
    private var displayPopover: Bool = false

    /// Application preferences model
    @ObservedObject
    private var prefs: AppPreferencesModel = .shared

    /// The source control model.
    @ObservedObject
    private var changesModel: SourceControlModel

    /// Initializes the ``ToolbarBranchPicker`` with an instance of a `FileSystemClient`
    /// 
    /// - Parameter shellClient: An instance of the current `ShellClient`
    /// - Parameter workspace: An instance of the current `FileSystemClient`
    public init(fileSystemClient: FileSystemClient?) {
        self.fileSystemClient = fileSystemClient
        self.changesModel = .init(
            workspaceURL: fileSystemClient?.folderURL ?? emptyURL
        )
    }

    /// The view body.
    public var body: some View {
        HStack(alignment: .center, spacing: 5) {
            if prefs.sourceControlActive() && changesModel.isGitRepository {
                Image("git.branch")
                    .font(.title3)
                    .imageScale(.medium)
                    .foregroundColor(controlActive == .inactive ? inactiveColor : .primary)
                    .accessibilityLabel(Text("Git Branche"))
            } else {
                Image(systemName: "square.dashed")
                    .font(.title3)
                    .imageScale(.medium)
                    .foregroundColor(controlActive == .inactive ? inactiveColor : .accentColor)
                    .accessibilityLabel(Text("No Source Control"))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(controlActive == .inactive ? inactiveColor : .primary)
                    .frame(height: 16)
                    .help(title)
                if prefs.sourceControlActive() && changesModel.isGitRepository {
                    if let currentBranch = changesModel.gitClient.publishedBranchName {
                        ZStack(alignment: .trailing) {
                            Text(currentBranch)
                                .padding(.trailing)
                            if isHovering {
                                Image(systemName: "chevron.down")
                                    .accessibilityLabel(Text("Open Branch Picker"))
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(controlActive == .inactive ? inactiveColor : .secondary)
                        .frame(height: 11)
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if prefs.sourceControlActive() && changesModel.isGitRepository {
                displayPopover.toggle()
            }
        }
        .accessibilityAddTraits(.isButton)
        .onHover { active in
            isHovering = active
        }
        .popover(isPresented: $displayPopover, arrowEdge: .bottom) {
            ToolbarBranchPicker.PopoverView(gitClient: changesModel.gitClient,
                                            currentBranch: changesModel.gitClient.publishedBranchName)
        }
    }

    /// The inactive color.
    private var inactiveColor: Color {
        Color(nsColor: .disabledControlTextColor)
    }

    /// The title of the branch picker.
    private var title: String {
        fileSystemClient?.folderURL?.lastPathComponent ?? "Empty"
    }

    // MARK: Popover View

    /// A popover view that appears once the branch picker is tapped.
    ///
    /// It displays the currently checked-out branch and all other local branches.
    /// 
    private struct PopoverView: View {

        /// The git client.
        var gitClient: GitClient?

        /// The current branch.
        @State
        var currentBranch: String?

        /// The view body.
        var body: some View {
            VStack(alignment: .leading) {
                if let currentBranch = currentBranch {
                    VStack(alignment: .leading, spacing: 0) {
                        headerLabel("Current Branch")
                        BranchCell(name: currentBranch, active: true) {}
                    }
                }
                if !branchNames.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            headerLabel("Branches")
                            ForEach(branchNames, id: \.self) { branch in
                                BranchCell(name: branch) {
                                    try? gitClient?.checkoutBranch(name: branch)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.top, 10)
            .padding(5)
            .frame(width: 340)
        }

        /// A header label.
        func headerLabel(_ title: String) -> some View {
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .padding(.vertical, 5)
        }

        // MARK: Branch Cell

        /// A Button Cell that represents a branch in the branch picker
        struct BranchCell: View {

            /// The dismiss environment.
            @Environment(\.dismiss)
            private var dismiss

            /// The branch name.
            var name: String

            /// The active state.
            var active: Bool = false

            /// The action to perform.
            var action: () -> Void

            /// The hover state.
            @State
            private var isHovering: Bool = false

            /// The view body.
            var body: some View {
                Button {
                    action()
                    dismiss()
                } label: {
                    HStack {
                        Label {
                            Text(name)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } icon: {
                            Image("git.branch")
                                .imageScale(.large)
                                .accessibilityLabel(Text("Git Branch"))
                        }
                        .foregroundColor(isHovering ? .white : .secondary)
                        if active {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(isHovering ? .white : .green)
                                .accessibilityLabel(Text("Active Branch"))
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
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
        }

        /// The branch names.
        var branchNames: [String] {
            // FIXME: Enable this
//            gitClient?.allBranches.map({ $0.name }).filter { $0 != currentBranch } ?? []
            return []
        }
    }
}
