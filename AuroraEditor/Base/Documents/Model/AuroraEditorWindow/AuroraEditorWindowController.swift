//
//  AuroraEditorWindowController.swift
//  AuroraEditor
//
//  Created by Pavel Kasila on 18.03.22.
//

import Cocoa
import SwiftUI

final class AuroraEditorWindowController: NSWindowController, ObservableObject {

    var prefs: AppPreferencesModel = .shared

    var workspace: WorkspaceDocument
    var overlayPanel: OverlayPanel?

    @Published
    var data = WindowDataStorage()

    var splitViewController: NSSplitViewController! {
        get { contentViewController as? NSSplitViewController }
        set { contentViewController = newValue }
    }

    init(window: NSWindow, workspace: WorkspaceDocument) {
        self.workspace = workspace
        super.init(window: window)

        self.data.windowController = self

        setupSplitView(with: workspace)
        setupToolbar()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSplitView(with workspace: WorkspaceDocument) {
        let splitVC = NSSplitViewController()

        let navigatorView = NavigatorSidebar(workspace: workspace).environmentObject(self)
        let navigator = NSSplitViewItem(
            sidebarWithViewController: NSHostingController(rootView: navigatorView)
        )
        navigator.titlebarSeparatorStyle = .none
        navigator.minimumThickness = 260
        navigator.collapseBehavior = .useConstraints
        splitVC.addSplitViewItem(navigator)

        let workspaceView = WorkspaceView(workspace: workspace).environmentObject(self)
        let mainContent = NSSplitViewItem(
            viewController: NSHostingController(rootView: workspaceView)
        )
        mainContent.titlebarSeparatorStyle = .line
        splitVC.addSplitViewItem(mainContent)

        let inspectorView = InspectorSidebar(workspace: workspace).environmentObject(self)
        let inspector = NSSplitViewItem(
            viewController: NSHostingController(rootView: inspectorView)
        )
        inspector.titlebarSeparatorStyle = .line
        inspector.minimumThickness = 260
        inspector.isCollapsed = !prefs.preferences.general.keepInspectorSidebarOpen
        inspector.collapseBehavior = .useConstraints
        splitVC.addSplitViewItem(inspector)

        self.splitViewController = splitVC
    }

    override func windowDidLoad() {
        super.windowDidLoad()
    }

    private func getSelectedCodeFile() -> CodeFileDocument? {
        guard let id = workspace.selectionState.selectedId else { return nil }
        guard let item = workspace.selectionState.openFileItems.first(where: { item in
            item.tabID == id
        }) else { return nil }
        guard let file = workspace.selectionState.openedCodeFiles[item] else { return nil }
        return file
    }

    // TODO: Make this more reliable
    @IBAction func saveDocument(_ sender: Any) {
        guard let file = getSelectedCodeFile() else {
            fatalError("Cannot get file")
        }

        for (id, AEExt) in ExtensionsManager.shared.loadedExtensions {
            Log.info(id, "didSave()")
            AEExt.respond(
                action: "didSave",
                parameters: [
                    "file": file.fileURL?.relativeString ?? "Unknown"
                ])
        }

//        file.save(sender)
        file.saveFileDocument()

        workspace.convertTemporaryTab()
    }

    @IBAction func openCommandPalette(_ sender: Any) {
        if let state = workspace.commandPaletteState {
            // if the panel exists, is open and is actually a command palette, close it.
            if let commandPalettePanel = overlayPanel, commandPalettePanel.isKeyWindow &&
                commandPalettePanel.viewType ?? .commandPalette == .commandPalette {
                commandPalettePanel.close()
                return
            }
            // else, init and show the command palette.
            let panel = OverlayPanel()
            configureOverlayPanel(panel: panel, content: NSHostingView(rootView: CommandPaletteView(
                state: state,
                onClose: { panel.close() },
                openFile: workspace.openTab(item:)
            )), viewType: .commandPalette)
            self.overlayPanel = panel
        }
    }

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

    func configureOverlayPanel(panel: OverlayPanel, content: NSView, viewType: OverlayPanel.ViewType? = nil) {
        panel.contentView = content
        // TODO: Fix bug where panel appears too high when it is created with preexisting items
        window?.addChildWindow(panel, ordered: .above)
        panel.makeKeyAndOrderFront(self)
        panel.viewType = viewType
    }

    // MARK: Git Main Menu Items

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
            data.showStashChangesSheet.toggle()
        }
    }

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
}
