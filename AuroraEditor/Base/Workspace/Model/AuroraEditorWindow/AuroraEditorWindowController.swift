//
//  Aurora EditorWindowController.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 18.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Cocoa
import SwiftUI
import Combine

// swiftlint:disable:next type_body_length
final class AuroraEditorWindowController: NSWindowController, ObservableObject {

    var prefs: AppPreferencesModel = .shared

    @ObservedObject
    private var model: NotificationsModel = .shared

    var workspace: WorkspaceDocument
    var overlayPanel: OverlayPanel?

    var cancelables: Set<AnyCancellable> = .init()

    var splitViewController: NSSplitViewController! {
        get { contentViewController as? NSSplitViewController }
        set { contentViewController = newValue }
    }

    init(window: NSWindow, workspace: WorkspaceDocument) {
        self.workspace = workspace
        super.init(window: window)

        self.workspace.data.windowController = self

        setupSplitView(with: self.workspace)
        setupToolbar()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // swiftlint:disable:next function_body_length
    private func setupSplitView(with workspace: WorkspaceDocument) {
        let splitVC = NSSplitViewController()

        let navigatorView = NavigatorSidebar().environmentObject(workspace)
        let navigator = NSSplitViewItem(
            sidebarWithViewController: NSHostingController(rootView: navigatorView)
        )
        navigator.titlebarSeparatorStyle = .none
        navigator.minimumThickness = 260
        navigator.collapseBehavior = .useConstraints
        splitVC.addSplitViewItem(navigator)

        let workspaceView = WorkspaceView().environmentObject(workspace)
        let mainContent = NSSplitViewItem(
            viewController: NSHostingController(rootView: workspaceView)
        )
        mainContent.titlebarSeparatorStyle = .line
        splitVC.addSplitViewItem(mainContent)

        let inspectorView = InspectorSidebar().environmentObject(workspace)
        let inspector = NSSplitViewItem(
            viewController: NSHostingController(rootView: inspectorView)
        )
        inspector.titlebarSeparatorStyle = .line
        inspector.minimumThickness = 260
        inspector.isCollapsed = !prefs.preferences.general.keepInspectorSidebarOpen
        inspector.collapseBehavior = .useConstraints
        splitVC.addSplitViewItem(inspector)

        // TODO: Find a way to show the notification again when
        // a new notification has been sent
        var view = NSTextField()
        view.frame = CGRect(x: 0, y: 0, width: 344, height: 104)
        view.isEditable = false
        view.layer?.cornerRadius = 12

        let header = NSView()
        header.frame = CGRect(x: 0, y: 0, width: 319, height: 16)

        // MARK: - Start of Notification Timestamp
        var time = NSTextView()
        time.frame = CGRect(x: 0, y: 0, width: 39, height: 14)
        time.alignment = .right
        time.string = "Now"
        // MARK: - End of Notification Timestamp

        let headerParent = header
        headerParent.addSubview(time)
        headerParent.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(header)

        var shadows = NSView()
        shadows.frame = view.frame
        view.addSubview(shadows)

        let shadowPath = NSBezierPath(roundedRect: shadows.bounds,
                                      xRadius: 12,
                                      yRadius: 12)
        let layer = CALayer()
        layer.shadowColor = NSColor(red: 0,
                                    green: 0,
                                    blue: 0,
                                    alpha: 0.16).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0,
                                    height: 5)
        layer.bounds = shadows.bounds
        shadows.layer?.addSublayer(layer)

        var shapes = NSView()
        shapes.frame = view.frame
        view.addSubview(shapes)

        let layer1 = CALayer()
        layer1.backgroundColor = NSColor(red: 0.146, green: 0.144, blue: 0.144, alpha: 0).cgColor
        layer1.bounds = shapes.bounds
        shapes.layer?.addSublayer(layer1)
        shapes.layer?.cornerRadius = 12

        var parent = splitVC.view
        parent.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false

        // This sets the width of the view
        let widthContraints = NSLayoutConstraint(item: view,
                                                  attribute: NSLayoutConstraint.Attribute.width,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: nil,
                                                  attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                  multiplier: 1,
                                                  constant: 344)

        // This sets the height of the view
        let heightContraints = NSLayoutConstraint(item: view,
                                                  attribute: NSLayoutConstraint.Attribute.height,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: nil,
                                                  attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                  multiplier: 1,
                                                  constant: 104)

        let xContraints = NSLayoutConstraint(item: view,
                                             attribute: NSLayoutConstraint.Attribute.bottom,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: parent,
                                             attribute: NSLayoutConstraint.Attribute.bottom,
                                             multiplier: 1,
                                             constant: -20)

        let yContraints = NSLayoutConstraint(item: view,
                                             attribute: NSLayoutConstraint.Attribute.trailing,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: parent,
                                             attribute: NSLayoutConstraint.Attribute.trailing,
                                             multiplier: 1,
                                             constant: -20)

        NSLayoutConstraint.activate([heightContraints,
                                     widthContraints,
                                     xContraints,
                                     yContraints])

        // Hides the notification after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.5

                // Animation that allows the view to slide out to
                // the left
                let transition = CATransition()
                transition.type = .push
                transition.subtype = .fromLeft

                // BUG: For some rease it adds another view
                // I'm assuming it has something to do with another
                // layer being added
                view.layer?.add(transition, forKey: nil )
            } completionHandler: {
                view.isHidden = true
            }
        }

        self.splitViewController = splitVC

        workspace.broadcaster.broadcaster
            .sink(receiveValue: recieveCommand).store(in: &cancelables)
    }

    override func close() {
        super.close()
        cancelables.forEach({ $0.cancel() })
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

    func openSettings() {
        if AppDelegate.tryFocusWindow(of: PreferencesView.self) { return }
        PreferencesView().showWindow()
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
            workspace.data.showStashChangesSheet.toggle()
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

    func recieveCommand(command: AuroraCommandBroadcaster.Broadcast) {
        let sender = command.parameters["sender"] ?? ""

        switch command.name {
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
