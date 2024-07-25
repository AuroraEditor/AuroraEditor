//
//  WorkspaceView.swift
//  Aurora Editor
//
//  Created by Austin Condiff on 3/10/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import AppKit
import Version_Control
import Combine
import OSLog

/// Workspace view.
struct WorkspaceView: View {
    /// The height of the tab bar.
    let tabBarHeight = 28.0

    /// Path of the workspace.
    private var path: String = ""

    /// The preferences model.
    @StateObject
    private var prefs: AppPreferencesModel = .shared

    /// The workspace document.
    @EnvironmentObject
    var workspace: WorkspaceDocument

    @EnvironmentObject
    var versionControl: VersionControlModel

    /// The notification service.
    let notificationService: NotificationService = .init()

    /// The cancelables.
    @State
    var cancelables: Set<AnyCancellable> = .init()

    /// The alert state.
    @State
    private var showingAlert = false

    /// The alert title.
    @State
    private var alertTitle = ""

    /// The alert message.
    @State
    private var alertMsg = ""

    /// The inspector state.
    @State
    var showInspector = true

    /// The fullscreen state of the NSWindow.
    /// This will be passed into all child views as an environment variable.
    @State
    var isFullscreen = false

    /// Enter fullscreen observer.
    @State
    private var enterFullscreenObserver: Any?

    /// Leave fullscreen observer.
    @State
    private var leaveFullscreenObserver: Any?

    /// The sheet state.
    @State
    var sheetIsOpened = false

    /// The dynamic extension data.
    @ObservedObject
    var extensionDynamic = ExtensionDynamicData()

    /// The extensions manager.
    let extensionsManagerShared = ExtensionsManager.shared

    /// Extension view storage.
    let extensionView = ExtensionViewStorage.shared

    /// Logger
    let logger = Logger(subsystem: "com.auroraeditor", category: "Workspace View")

    /// Tab content
    /// 
    /// - Parameter tabID: The tab ID
    /// 
    /// - Returns: The view
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
        case .extensionCustomView:
            if let customTab = workspace.selectionState.selected as? ExtensionCustomViewModel {
                ExtensionCustomView(view: extensionView.storage.first(where: {
                    $0.key == customTab.id
                })?.value, sender: customTab.sender)
            }
        }
    }

    /// The view body.
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
                            .init(workspaceURL: workspace.documentURL))
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

            workspace.broadcaster.broadcaster.sink { broadcast in
                broadcastHandler(broadcast: broadcast)
            }.store(in: &cancelables)
        }
        .onDisappear {
            // Unregister the observer when the view is going to disappear.
            if let enterFullscreenObserver = enterFullscreenObserver {
                NotificationCenter.default.removeObserver(enterFullscreenObserver)
            }
            if let leaveFullscreenObserver = leaveFullscreenObserver {
                NotificationCenter.default.removeObserver(leaveFullscreenObserver)
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
            StashChangesSheet(workspaceURL: workspace.folderURL)
        }
        .sheet(isPresented: $workspace.data.showRenameBranchSheet) {
            RenameBranchView(workspace: workspace,
                             branch: workspace.data.currentBranch,
                             newBranchName: workspace.data.currentlySelectedBranch)
            .environmentObject(versionControl)
        }
        .sheet(isPresented: $workspace.data.showAddRemoteView) {
            AddRemoteView(workspace: workspace)
        }
        .sheet(isPresented: $workspace.data.showBranchCreationSheet) {
            CreateNewBranchView(workspace: workspace,
                                revision: workspace.data.branchRevision,
                                revisionDesciption: workspace.data.branchRevisionDescription)
            .environmentObject(versionControl)
        }
        .sheet(isPresented: $workspace.data.showTagCreationSheet) {
            CreateNewTagView(workspace: workspace,
                             commitHash: workspace.data.commitHash)

        }
        .sheet(isPresented: $sheetIsOpened) {
            VStack {
                HStack {
                    Text(extensionDynamic.title)
                    Spacer()
                    Button("Dismiss") {
                        sheetIsOpened.toggle()
                    }
                }.padding([.leading, .top, .trailing], 5)
                Divider()
                extensionDynamic.view
                    .padding(.bottom, 5)
            }
            .frame(minWidth: 250, minHeight: 150)
        }
    }
}

struct WorkspaceView_Previews: PreviewProvider {
    static var previews: some View {
        WorkspaceView()
    }
}

/// Environment key for the fullscreen state.
private struct WorkspaceFullscreenStateEnvironmentKey: EnvironmentKey {
    /// The default value.
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    /// Is fullscreen state.
    var isFullscreen: Bool {
        get { self[WorkspaceFullscreenStateEnvironmentKey.self] }
        set { self[WorkspaceFullscreenStateEnvironmentKey.self] = newValue }
    }
}
