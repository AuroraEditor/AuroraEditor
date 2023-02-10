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

final class AuroraEditorWindowController: NSWindowController, ObservableObject {

    var prefs: AppPreferencesModel = .shared

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

        // This parent fetches the whole apps window since AE is built around
        // a split editor view.
        let parent = splitVC.view

        // We create a empty NSView to be able to allow sending up to date notification
        // toast when a new `info` notification is being sent to the user.
        var notificationView = NSView()

        // When there is an update in the `notificationToastData` publisher we featch those
        // changes and then apply the proper view by replacing the empty `NSView` with a
        // `NSHostingView` than contains the `NotificationToastView`.
        //
        // Before showing the toast we make sure the view is hidden and then add the constraints
        // to position it correctly in the bottom right corner.
        model.$notificationToastData.sink { data in
            notificationView = NSHostingView(rootView: NotificationToastView(notification: data))
            parent.addSubview(notificationView)
            notificationView.isHidden = true
            notificationView.translatesAutoresizingMaskIntoConstraints = false

            // This sets the width of the view
            let widthContraints = NSLayoutConstraint(item: notificationView,
                                                      attribute: NSLayoutConstraint.Attribute.width,
                                                      relatedBy: NSLayoutConstraint.Relation.equal,
                                                      toItem: nil,
                                                      attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                      multiplier: 1,
                                                      constant: 344)

            // This sets the height of the view
            let heightContraints = NSLayoutConstraint(item: notificationView,
                                                      attribute: NSLayoutConstraint.Attribute.height,
                                                      relatedBy: NSLayoutConstraint.Relation.equal,
                                                      toItem: nil,
                                                      attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                      multiplier: 1,
                                                      constant: 104)

            let xContraints = NSLayoutConstraint(item: notificationView,
                                                 attribute: NSLayoutConstraint.Attribute.bottom,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: parent,
                                                 attribute: NSLayoutConstraint.Attribute.bottom,
                                                 multiplier: 1,
                                                 constant: -20)

            let yContraints = NSLayoutConstraint(item: notificationView,
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
        }.store(in: &cancelables)

        // This sink allows us to observe if we should show the notification toast
        // view. When the `showNotificationToast` value changes, we check if it's true
        // if it is we put the `notificationView` hidden to false allowing us to show it
        // to the user.
        //
        // When showing the notification it will transion into the editor from
        // the right, after that animation is complete we will run a timer that will be
        // delayed by 5 seconds which will then run another animation that will transition
        // it to the left, after that is done we toggle `notificationView` to be hidden again
        // and also toggle the `showNotificationToast` to be off.
        model.$showNotificationToast.sink { showToast in
            notificationView.isHidden = !showToast

            if showToast {
                notificationView.isHidden = !showToast

                NSAnimationContext.runAnimationGroup { context in
                    context.duration = 0.3

                    // Animation that allows the view to slide in
                    // from the right
                    let transition = CATransition()
                    transition.type = .push
                    transition.subtype = .fromRight

                    notificationView.layer?.add(transition, forKey: nil )
                } completionHandler: {
                    self.model.$hoveringOnToast.sink { isHovering in
                        if !isHovering {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                NSAnimationContext.runAnimationGroup { context in
                                    context.duration = 0.3

                                    // Animation that allows the view to slide out to
                                    // the left
                                    let transition = CATransition()
                                    transition.type = .push
                                    transition.subtype = .fromLeft

                                    // BUG: For some rease it adds another view
                                    // I'm assuming it has something to do with another
                                    // layer being added
                                    notificationView.layer?.add(transition, forKey: nil )
                                } completionHandler: {
                                    notificationView.isHidden = true

                                    self.model.showNotificationToast = false
                                }
                            }
                        }
                    }.store(in: &self.cancelables)
                }
            }
        }.store(in: &cancelables)

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
