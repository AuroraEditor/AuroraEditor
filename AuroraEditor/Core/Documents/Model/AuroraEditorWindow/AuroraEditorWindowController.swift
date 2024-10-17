//
//  Aurora EditorWindowController.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 18.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Combine

/// The window controller for Aurora Editor.
@MainActor
final class AuroraEditorWindowController: NSWindowController, ObservableObject {
    /// The preferences model.
    @Published
    var prefs: AppPreferencesModel = .shared

    /// The notifications model.
    private var model: NotificationsModel = .shared

    /// The workspace document.
    var workspace: WorkspaceDocument

    var versionControl: VersionControlModel = .shared

    /// The overlay panel.
    var overlayPanel: OverlayPanel?

    /// The notification animator.
    var notificationAnimator: NotificationViewAnimator!

    /// The set of cancelables.
    var cancelables: Set<AnyCancellable> = .init()

    /// The split view controller.
    var splitViewController: AuroraSplitViewController! {
        get { contentViewController as? AuroraSplitViewController }
        set { contentViewController = newValue }
    }

    /// Creates a new instance of the window controller.
    /// 
    /// - Parameter window: The window.
    /// - Parameter workspace: The workspace document.
    init(window: NSWindow, workspace: WorkspaceDocument) {
        self.workspace = workspace
        super.init(window: window)

        self.workspace.data.windowController = self

        setupSplitView(with: workspace)
        setupToolbar()

        updateLayoutOfWindowAndSplitView()

        versionControl.initializeModel(workspaceURL: workspace.folderURL)
    }

    /// Creates a new instance of the window controller.
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Setup split view.
    /// 
    /// - Parameter workspace: The workspace document.
    private func setupSplitView(with workspace: WorkspaceDocument) { // swiftlint:disable:this function_body_length
        let splitVC = AuroraSplitViewController(prefs: prefs)
        splitVC.splitView.autosaveName = "MainSplitView"
        splitVC.splitView.dividerStyle = .thin
        splitVC.splitView.isVertical = true

        // Navigator Sidebar
        let navigatorView = NavigatorSidebar()
            .environmentObject(workspace)
            .environmentObject(versionControl)
        let navigationViewController = NSHostingController(
            rootView: navigatorView
        )
        let navigator = NSSplitViewItem(
            sidebarWithViewController: navigationViewController
        )
        navigator.titlebarSeparatorStyle = .none
        navigator.minimumThickness = 200
        navigator.maximumThickness = 400
        navigator.collapseBehavior = .useConstraints
        navigator.canCollapse = true
        navigator.isSpringLoaded = true
        navigator.holdingPriority = NSLayoutConstraint.Priority(
            NSLayoutConstraint.Priority.defaultLow.rawValue + 1
        )
        splitVC.addSplitViewItem(navigator)

        // Workspace (Main Content)
        let workspaceView = WorkspaceView()
            .environmentObject(workspace)
            .environmentObject(versionControl)
        let workspaceViewController = NSHostingController(
            rootView: workspaceView
        )
        let mainContent = NSSplitViewItem(
            viewController: workspaceViewController
        )
        mainContent.titlebarSeparatorStyle = .line
        mainContent.holdingPriority = .defaultLow
        splitVC.addSplitViewItem(mainContent)

        // Inspector Sidebar
        let inspectorView = InspectorSidebar(prefs: prefs)
            .environmentObject(workspace)
        let inspectorViewController = NSHostingController(
            rootView: inspectorView
        )
        let inspector = NSSplitViewItem(
            inspectorWithViewController: inspectorViewController
        )
        inspector.titlebarSeparatorStyle = .none
        inspector.minimumThickness = 200
        inspector.maximumThickness = 400
        inspector.canCollapse = true
        inspector.collapseBehavior = .useConstraints
        inspector.isSpringLoaded = true
        inspector.isCollapsed = !prefs.preferences.general.keepInspectorSidebarOpen
        inspector.holdingPriority = NSLayoutConstraint.Priority(
            NSLayoutConstraint.Priority.defaultLow.rawValue + 1
        )
        splitVC.addSplitViewItem(inspector)

        // Set up the initial sidebar states
        splitVC.toggleSidebar(navigator)
        splitVC.toggleSidebar(inspector)

        // Create an instance of NotificationViewAnimator
        notificationAnimator = NotificationViewAnimator(
            notificationView: NSView(),
            parent: splitVC.view,
            model: model
        )

        notificationAnimator.observeNotificationData()
        notificationAnimator.observeShowNotification()

        self.splitViewController = splitVC

        workspace.broadcaster.broadcaster
            .sink(receiveValue: recieveBroadcast).store(in: &cancelables)
    }

    /// Close the window.
    override func close() {
        super.close()
        cancelables.forEach({ $0.cancel() })
    }

    /// Update the layout of the window and split view.
    @objc
    private func updateLayoutOfWindowAndSplitView() {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            let navigationSidebarWidth = self.prefs.preferences.general.navigationSidebarWidth
            let workspaceSidebarWidth = self.prefs.preferences.general.workspaceSidebarWidth
            let firstDividerPos = navigationSidebarWidth
            let secondDividerPos = navigationSidebarWidth + workspaceSidebarWidth

            self.window?.setContentSize(
                CGSize(
                    width: self.prefs.preferences.general.auroraEditorWindowWidth,
                    height: 600
                )
            )
            self.splitViewController.splitView.setPosition(firstDividerPos, ofDividerAt: 0)
            self.splitViewController.splitView.setPosition(secondDividerPos, ofDividerAt: 1)
            self.splitViewController.splitView.layoutSubtreeIfNeeded()
        }
    }

    /// Get the selected code file.
    /// 
    /// - Returns: The selected code file.
    private func getSelectedCodeFile() -> CodeFileDocument? {
        guard let id = workspace.selectionState.selectedId else { return nil }
        guard let item = workspace.selectionState.openFileItems.first(where: { item in
            item.tabID == id
        }) else { return nil }
        guard let file = workspace.selectionState.openedCodeFiles[item] else { return nil }
        return file
    }

    /// Save the document.
    /// 
    /// - Parameter sender: The sender.
    @IBAction func saveDocument(_ sender: Any) {
        guard let file = getSelectedCodeFile() else {
            fatalError("Cannot get file")
        }

        ExtensionsManager.shared.sendEvent(
            event: "didSave",
            parameters: ["file": file.fileURL?.relativeString ?? "Unknown"]
        )

        file.saveFileDocument()

        workspace.convertTemporaryTab()
    }

    /// Open command palette.
    /// 
    /// - Parameter sender: The sender.
    @IBAction func openCommandPalette(_ sender: Any) {
        if let state = workspace.commandPaletteState {
            // if the panel exists, is open and is actually a command palette, close it.
            if let commandPalettePanel = overlayPanel, commandPalettePanel.isKeyWindow &&
                commandPalettePanel.viewType ?? .commandPalette == .commandPalette {
                ExtensionsManager.shared.sendEvent(
                    event: "commandPalletteDidDisappear",
                    parameters: [:]
                )

                commandPalettePanel.close()
                return
            }
            // else, init and show the command palette.
            let panel = OverlayPanel()
            configureOverlayPanel(panel: panel, content: NSHostingView(rootView: CommandPaletteView(
                state: state,
                onClose: {
                    ExtensionsManager.shared.sendEvent(
                        event: "commandPalletteDidDisappear",
                        parameters: [:]
                    )

                    panel.close()
                },
                openFile: workspace.openTab(item:)
            )), viewType: .commandPalette)
            self.overlayPanel = panel
        }
    }

    /// Open quick open.
    /// 
    /// - Parameter sender: The sender.
    @IBAction func openQuickly(_ sender: Any) {
        if let state = workspace.quickOpenState {
            // if the panel exists, is open and is actually a quick open panel, close it.
            if let quickOpenPanel = overlayPanel, quickOpenPanel.isKeyWindow &&
                quickOpenPanel.viewType ?? .quickOpen == .quickOpen {
                quickOpenPanel.close()
                return
            }
            // else, init and show the quick open panel
            let panel = OverlayPanel()
            configureOverlayPanel(panel: panel, content: NSHostingView(rootView: QuickOpenView(
                state: state,
                onClose: { panel.close() },
                openFile: workspace.openTab(item:)
            )), viewType: .quickOpen)
            self.overlayPanel = panel
        }
    }

    /// Configure overlay panel.
    /// 
    /// - Parameter panel: The overlay panel.
    /// - Parameter content: The content.
    /// - Parameter viewType: The view type.
    func configureOverlayPanel(panel: OverlayPanel, content: NSView, viewType: OverlayPanel.ViewType? = nil) {
        panel.contentView = content
        window?.addChildWindow(panel, ordered: .above)
        panel.makeKeyAndOrderFront(self)
        panel.viewType = viewType
    }

    /// Open settings.
    func openSettings() {
        if AppDelegate.tryFocusWindow(of: PreferencesView.self) { return }
        PreferencesView().showWindow()
    }

    // MARK: Git Main Menu Items

    /// Stash changes items.
    /// 
    /// - Parameter sender: The sender.
    @IBAction func stashChangesItems(_ sender: Any) {
        if AppDelegate.tryFocusWindow(of: StashChangesSheet.self) { return }
        if (workspace.fileSystemClient?.model?.changed ?? []).isEmpty {
            let alert = NSAlert()
            alert.alertStyle = .informational
            alert.messageText = "Cannot Stash Changes"
            alert.informativeText = "There are no uncommitted changes in the working copies for this project."
            alert.addButton(withTitle: "OK")
            alert.runModal()
        } else {
            workspace.data.showStashChangesSheet.toggle()
        }
    }

    /// Discard project changes.
    /// 
    /// - Parameter sender: The sender.
    @IBAction func discardProjectChanges(_ sender: Any) {
        if (workspace.fileSystemClient?.model?.changed ?? []).isEmpty {
            let alert = NSAlert()
            alert.alertStyle = .informational
            alert.messageText = "Cannot Discard Changes"
            alert.informativeText = "There are no uncommitted changes in the working copies for this project."
            alert.addButton(withTitle: "OK")
            alert.runModal()
        } else {
            workspace.fileSystemClient?.model?.discardProjectChanges()
        }
    }

    /// Receive broadcast.
    /// 
    /// - Parameter broadcast: The broadcast.
    /// 
    /// - Note: This method is called when a broadcast is received.
    func recieveBroadcast(broadcast: AuroraCommandBroadcaster.Broadcast) {
        let sender = broadcast.parameters["sender"] ?? ""

        switch broadcast.command {
        case "openQuickly":
            openQuickly(sender)
        case "close":
            close()
        case "toggleToolbarShown":
            window?.toggleToolbarShown(sender)
        case "runToolbarCustomization":
            window?.runToolbarCustomizationPalette(sender)
        case "toggleSidebar":
            splitViewController.toggleSidebar(sender)
        case "toggleFullScreen":
            window?.toggleFullScreen(sender)
        case "discardProjectChanges":
            discardProjectChanges(sender)
        case "miniaturize":
            window?.miniaturize(sender)
        case "zoom":
            window?.zoom(sender)
        default: break
        }
    }
}
