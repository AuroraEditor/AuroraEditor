//
//  ToolbarBranchPicker.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 07.07.24.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Combine
import Version_Control

/// A view that pops up a branch picker.
public struct ToolbarBranchPicker: View {
    // MARK: - Environment

    /// The active state of the control.
    @Environment(\.controlActiveState)
    private var controlActive

    // MARK: - Properties

    /// The file system client.
    @ObservedObject
    var workspace: WorkspaceDocument

    @EnvironmentObject
    var versionControl: VersionControlModel

    /// The hover state.
    @State
    private var isHovering: Bool = false

    /// The display popover state.
    @State
    private var displayPopover: Bool = false

    @State
    private var workspaceName: String = ""

    /// Application preferences model.
    @ObservedObject
    private var prefs: AppPreferencesModel = .shared

    init(workspace: WorkspaceDocument) {
        self.workspace = workspace
    }

    /// The view body.
    public var body: some View {
        HStack(alignment: .center, spacing: 5) {
            branchIcon
            branchDetails
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if prefs.sourceControlActive() && versionControl.workspaceIsRepository {
                displayPopover.toggle()
            }
        }
        .accessibilityAddTraits(.isButton)
        .onHover { active in
            isHovering = active
        }
        .popover(isPresented: $displayPopover, arrowEdge: .bottom) {
            BranchPopoverList(
                workspace: workspace,
                currentBranch: versionControl.currentBranchObject
            )
        }
    }

    // MARK: - Private Views

    /// Branch icon based on the source control state.
    private var branchIcon: some View {
        Group {
            if prefs.sourceControlActive() && versionControl.workspaceIsRepository {
                Image("git.branch")
                    .font(.title3)
                    .imageScale(.medium)
                    .foregroundColor(controlActive == .inactive ? inactiveColor : .primary)
                    .accessibilityLabel(Text("Git Branch"))
            } else {
                Image(systemName: "square.dashed")
                    .font(.title3)
                    .imageScale(.medium)
                    .foregroundColor(controlActive == .inactive ? inactiveColor : .accentColor)
                    .accessibilityLabel(Text("No Source Control"))
            }
        }
    }

    /// Branch details including the title and current branch.
    private var branchDetails: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(workspaceName)
                .font(.headline)
                .foregroundColor(controlActive == .inactive ? inactiveColor : .primary)
                .frame(height: 16)
                .help(workspaceName)

            if prefs.sourceControlActive() && versionControl.workspaceIsRepository {
                branchNameView(currentBranch: versionControl.currentWorkspaceBranch)
            }
        }
        .onAppear {
            self.workspaceName = workspace.folderURL.lastPathComponent
        }
    }

    /// The view for displaying the current branch name.
    private func branchNameView(currentBranch: String) -> some View {
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

    // MARK: - Computed Properties

    /// The inactive color.
    private var inactiveColor: Color {
        Color(nsColor: .disabledControlTextColor)
    }
}
