//
//  ToolbarBranchPicker.swift
//  AuroraEditorModules/AuroraEditorUI
//
//  Created by Lukas Pistrol on 21.04.22.
//

import SwiftUI
import Combine

/// A view that pops up a branch picker.
public struct ToolbarBranchPicker: View {
    @Environment(\.controlActiveState)
    private var controlActive
    private var fileSystemClient: FileSystemClient?

    @State
    private var isHovering: Bool = false

    @State
    private var displayPopover: Bool = false

    @ObservedObject
    private var prefs: AppPreferencesModel = .shared

    @ObservedObject
    private var changesModel: SourceControlModel

    /// Initializes the ``ToolbarBranchPicker`` with an instance of a `FileSystemClient`
    /// - Parameter shellClient: An instance of the current `ShellClient`
    /// - Parameter workspace: An instance of the current `FileSystemClient`
    public init(fileSystemClient: FileSystemClient?) {
        self.fileSystemClient = fileSystemClient
        self.changesModel = .init(workspaceURL: (fileSystemClient?.folderURL)!)
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 5) {
            if prefs.sourceControlActive() && changesModel.isGitRepository {
                Image("git.branch")
                    .font(.title3)
                    .imageScale(.medium)
                    .foregroundColor(controlActive == .inactive ? inactiveColor : .primary)
            } else {
                Image(systemName: "square.dashed")
                    .font(.title3)
                    .imageScale(.medium)
                    .foregroundColor(controlActive == .inactive ? inactiveColor : .accentColor)
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
        .onHover { active in
            isHovering = active
        }
        .popover(isPresented: $displayPopover, arrowEdge: .bottom) {
            ToolbarBranchPicker.PopoverView(gitClient: changesModel.gitClient,
                                            currentBranch: changesModel.gitClient.publishedBranchName)
        }
    }

    private var inactiveColor: Color {
        Color(nsColor: .disabledControlTextColor)
    }

    private var title: String {
        fileSystemClient?.folderURL?.lastPathComponent ?? "Empty"
    }

    // MARK: Popover View

    /// A popover view that appears once the branch picker is tapped.
    ///
    /// It displays the currently checked-out branch and all other local branches.
    private struct PopoverView: View {

        var gitClient: GitClient?

        @State
        var currentBranch: String

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
            @Environment(\.dismiss) private var dismiss

            var name: String
            var active: Bool = false
            var action: () -> Void

            @State
            private var isHovering: Bool = false

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
                        }
                        .foregroundColor(isHovering ? .white : .secondary)
                        if active {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(isHovering ? .white : .green)
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

        var branchNames: [String] {
            ((try? gitClient?.getGitBranches(allBranches: false)) ?? []).filter { $0 != currentBranch }
        }
    }
}
