//
//  WorkspaceView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/10/22.
//

import SwiftUI
import AppKit
import Version_Control

struct WorkspaceView: View {
    init(workspace: WorkspaceDocument) {
        self.workspace = workspace
    }

    let tabBarHeight = 28.0
    private var path: String = ""

    @ObservedObject
    var workspace: WorkspaceDocument

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @EnvironmentObject
    private var window: AuroraEditorWindowController

    @State
    private var showingAlert = false

    @State
    private var alertTitle = ""

    @State
    private var alertMsg = ""

    @State
    var showInspector = true

    /// The fullscreen state of the NSWindow.
    /// This will be passed into all child views as an environment variable.
    @State
    var isFullscreen = false

    @State
    private var enterFullscreenObserver: Any?

    @State
    private var leaveFullscreenObserver: Any?

    @ViewBuilder var tabContent: some View {
        if let tabID = workspace.selectionState.selectedId {
            switch tabID {
            case .codeEditor:
                WorkspaceCodeFileView(workspace: workspace)
            case .extensionInstallation:
                EmptyView()

            case .webTab:
                if let webTab = workspace.selectionState.selected as? WebTab {
                    WebTabView(webTab: webTab)
                }
            case .projectHistory:
                if let projectHistoryTab = workspace.selectionState.selected as? ProjectCommitHistory {
                    ProjectCommitHistoryView(projectHistoryModel: projectHistoryTab,
                                             workspace: workspace)
                }
            case .branchHistory:
                if let branchHistoryTab = workspace.selectionState.selected as? BranchCommitHistory {
                    BranchCommitHistoryView(branchCommitModel: branchHistoryTab)
                }
            case .actionsWorkflow:
                if let actionsWorkflowTab = workspace.selectionState.selected as? Workflow {
                    WorkflowRunsView(workspace: workspace,
                                     workflowId: String(actionsWorkflowTab.id))
                }
            }
        } else {
            EmptyEditorView()
        }
    }

    var body: some View {
        ZStack {
            if workspace.fileSystemClient != nil, let model = workspace.statusBarModel {
                ZStack {
                    tabContent
                }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background {
                        if prefs.preferences.general.tabBarStyle == .xcode {
                            // Use the same background material as xcode tab bar style.
                            // Only when the tab bar style is set to `xcode`.
                            TabBarXcodeBackground()
                        }
                    }
                    .safeAreaInset(edge: .top, spacing: 0) {
                        VStack(spacing: 0) {
                            TabBar(workspace: workspace)
                            Divider().foregroundColor(.secondary)
                        }
                    }
                    .safeAreaInset(edge: .bottom) {
                        StatusBarView(model: model, workspace: workspace)
                    }
            } else {
                EmptyView()
            }
        }
        .alert(alertTitle, isPresented: $showingAlert, actions: {
            Button(
                action: { showingAlert = false },
                label: { Text("OK") }
            )
        }, message: { Text(alertMsg) })
        .onChange(of: workspace.selectionState.selectedId) { newValue in
            if newValue == nil {
                window.window?.subtitle = ""
            }
        }
        .onAppear {
            // There may be other methods to monitor the full-screen state.
            // But I cannot find a better one for now because I need to pass this into the SwiftUI.
            // And it should always be updated.
            enterFullscreenObserver = NotificationCenter.default.addObserver(
                forName: NSWindow.didEnterFullScreenNotification,
                object: nil,
                queue: .current,
                using: { _ in self.isFullscreen = true }
            )
            leaveFullscreenObserver = NotificationCenter.default.addObserver(
                forName: NSWindow.willExitFullScreenNotification,
                object: nil,
                queue: .current,
                using: { _ in self.isFullscreen = false }
            )
        }
        .onDisappear {
            // Unregister the observer when the view is going to disappear.
            if enterFullscreenObserver != nil {
                NotificationCenter.default.removeObserver(enterFullscreenObserver!)
            }
            if leaveFullscreenObserver != nil {
                NotificationCenter.default.removeObserver(leaveFullscreenObserver!)
            }
        }
        // Send the environment to all subviews.
        .environment(\.isFullscreen, self.isFullscreen)
        // When tab bar style is changed, update NSWindow configuration as follows.
        .onChange(of: prefs.preferences.general.tabBarStyle) { newStyle in
            DispatchQueue.main.async {
                if newStyle == .native {
                    window.window?.titlebarAppearsTransparent = true
                    window.window?.titlebarSeparatorStyle = .none
                } else {
                    window.window?.titlebarAppearsTransparent = false
                    window.window?.titlebarSeparatorStyle = .automatic
                }
            }
        }
        .sheet(isPresented: $workspace.newFileModel.showFileCreationSheet) {
            FileCreationSelectionView(workspace: workspace)
        }
        .sheet(isPresented: $window.data.showStashChangesSheet) {
            StashChangesSheet(workspaceURL: workspace.workspaceURL())
        }
        .sheet(isPresented: $window.data.showRenameBranchSheet) {
            RenameBranchView(workspace: workspace,
                             currentBranchName: window.data.currentlySelectedBranch,
                             newBranchName: window.data.currentlySelectedBranch)
        }
        .sheet(isPresented: $window.data.showAddRemoteView) {
            AddRemoteView(workspace: workspace)
        }
        .sheet(isPresented: $window.data.showBranchCreationSheet) {
            CreateNewBranchView(workspace: workspace,
                                revision: window.data.branchRevision,
                                revisionDesciption: window.data.branchRevisionDescription)
        }
    }
}

struct WorkspaceView_Previews: PreviewProvider {
    static var previews: some View {
        WorkspaceView(workspace: .init())
    }
}

private struct WorkspaceFullscreenStateEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isFullscreen: Bool {
        get { self[WorkspaceFullscreenStateEnvironmentKey.self] }
        set { self[WorkspaceFullscreenStateEnvironmentKey.self] = newValue }
    }
}
