//
//  WorkspaceView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/10/22.
//

import SwiftUI
import AppKit
import Version_Control
import Combine

struct WorkspaceView: View {

    let tabBarHeight = 28.0
    private var path: String = ""

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @EnvironmentObject
    private var workspace: WorkspaceDocument

    @State
    var cancelables: Set<AnyCancellable> = .init()

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

    private let extensionsManagerShared = ExtensionsManager.shared

    @ViewBuilder
    func tabContentForID(tabID: TabBarItemID) -> some View {
        switch tabID {
        case .codeEditor:
            WorkspaceCodeFileView()
        case .extensionInstallation:
            if let plugin = workspace.selectionState.selected as? Plugin {
                ExtensionView(extensionData: plugin)
            }
        case .webTab:
            if let webTab = workspace.selectionState.selected as? WebTab {
                WebTabView(webTab: webTab)
            }
        case .projectHistory:
            if let projectHistoryTab = workspace.selectionState.selected as? ProjectCommitHistory {
                ProjectCommitHistoryView(projectHistoryModel: projectHistoryTab)
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
    }

    var body: some View {
        ZStack {
            if workspace.fileSystemClient != nil, let model = workspace.statusBarModel {
                ZStack {
                    if let tabID = workspace.selectionState.selectedId {
                        tabContentForID(tabID: tabID)
                    } else {
                        EmptyEditorView()
                    }
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
                            TabBar(sourceControlModel: workspace.fileSystemClient?.model ??
                                .init(workspaceURL: workspace.fileURL!))
                            Divider().foregroundColor(.secondary)
                        }
                    }
                    .safeAreaInset(edge: .bottom) {
                        StatusBarView(model: model)
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
                workspace.windowController?.window?.subtitle = ""
            }
        }
        .onAppear {
            extensionsManagerShared.set(workspace: workspace)
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

            workspace.broadcaster.broadcaster.sink { command in
                if command.name == "openSettings" {
                    workspace.windowController?.openSettings()
                }
                if command.name == "showNotification",
                   let message = command.parameters["message"] as? String {
                    workspace.notificationList.append(message)
                }
                if command.name == "showWarning",
                   let message = command.parameters["message"] as? String {
                    workspace.warningList.append(message)
                }
                if command.name == "showError",
                   let message = command.parameters["message"] as? String {
                    workspace.errorList.append(message)
                }
            }.store(in: &cancelables)
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
                    workspace.windowController?.window?.titlebarAppearsTransparent = true
                    workspace.windowController?.window?.titlebarSeparatorStyle = .none
                } else {
                    workspace.windowController?.window?.titlebarAppearsTransparent = false
                    workspace.windowController?.window?.titlebarSeparatorStyle = .automatic
                }
            }
        }
        .sheet(isPresented: $workspace.newFileModel.showFileCreationSheet) {
            FileCreationSelectionView(workspace: workspace)
        }
        .sheet(isPresented: $workspace.data.showStashChangesSheet) {
            StashChangesSheet(workspaceURL: workspace.workspaceURL())
        }
        .sheet(isPresented: $workspace.data.showRenameBranchSheet) {
            RenameBranchView(workspace: workspace,
                             currentBranchName: workspace.data.currentlySelectedBranch,
                             newBranchName: workspace.data.currentlySelectedBranch)
        }
        .sheet(isPresented: $workspace.data.showAddRemoteView) {
            AddRemoteView(workspace: workspace)
        }
        .sheet(isPresented: $workspace.data.showBranchCreationSheet) {
            CreateNewBranchView(workspace: workspace,
                                revision: workspace.data.branchRevision,
                                revisionDesciption: workspace.data.branchRevisionDescription)
        }
        .sheet(isPresented: $workspace.data.showTagCreationSheet) {
            CreateNewTagView(workspace: workspace,
                             commitHash: workspace.data.commitHash)

        }
    }
}

struct WorkspaceView_Previews: PreviewProvider {
    static var previews: some View {
        WorkspaceView()
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
