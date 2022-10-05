//
//  SourceControlMenu.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/10.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI
import Version_Control

final class SourceControlMenu: NSMenu {

    typealias Item = FileItem

    private let gitClient: GitClient

    var item: Item?

    var workspace: WorkspaceDocument?

    private let fileManger = FileManager.default

    private var outlineView: NSOutlineView

    init(sender: NSOutlineView, workspaceURL: URL) {
        outlineView = sender
        gitClient = GitClient.init(
            directoryURL: workspaceURL,
            shellClient: sharedShellClient.shellClient
        )
        super.init(title: "Source Control Options")
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func menuItem(_ title: String, action: Selector?, key: String = "") -> NSMenuItem {
        let mItem = NSMenuItem(title: title, action: action, keyEquivalent: key)
        mItem.target = self

        return mItem
    }

    private func setupMenu() {

        let showInFinder = menuItem("Show in Finder", action: #selector(showInFinder))
        let revealInProjectNav = menuItem("Reveal in Project Navigator", action: nil)

        let openInTab = menuItem("Open in Tab", action: #selector(openInTab))
        let openInNewWindow = menuItem("Open in New Indow", action: nil)
        let openExternalEditor = menuItem("Open with External Editor", action: #selector(openWithExternalEditor))

        let commitFile = menuItem("Commit \"\(item?.fileName ?? "Selected Files")\"...", action: nil)

        let discardChanges = menuItem("Discard Changes in \"\(item?.fileName ?? "Selected Files")\"...",
                                      action: #selector(discardChangesInFile))

        let addSelectedFiles = menuItem("Add Selected Files...", action: nil)
        let markAsResolved = menuItem("Mark Selected Files as Resolved", action: nil)

        items = [
            showInFinder,
            revealInProjectNav,
            NSMenuItem.separator(),
            openInTab,
            openInNewWindow,
            openExternalEditor,
            NSMenuItem.separator(),
            commitFile,
            NSMenuItem.separator(),
            discardChanges,
            NSMenuItem.separator(),
            addSelectedFiles,
            markAsResolved
        ]
    }

    /// Updates the menu for the selected item and hides it if no item is provided.
    override func update() {
        removeAllItems()
        setupMenu()
    }

    /// Action that opens **Finder** at the items location.
    @objc
    private func showInFinder() {
        item?.showInFinder()
    }

    /// Action that opens the item, identical to clicking it.
    @objc
    private func openInTab() {
        if let item = item {
            workspace?.openTab(item: item)
        }
    }

    /// Action that opens in an external editor
    @objc
    private func openWithExternalEditor() {
        item?.openWithExternalEditor()
    }

    // MARK: Source Control
    @objc
    private func commitFile() {

    }

    // TODO: Need to find a way to check for changes in the current selected file
    @objc
    private func discardChangesInFile() {
        let alert = NSAlert()
        alert.messageText = "Do you want to permanently discard all changes to \"\(item?.fileName ?? "")\"?"
        alert.informativeText = "You can't undo this action"
        alert.alertStyle = .critical
        alert.addButton(withTitle: "Discard Changes")
        alert.buttons.last?.hasDestructiveAction = true
        alert.addButton(withTitle: "Cancel")
        if alert.runModal() == .alertFirstButtonReturn {
            do {
                try gitClient.discardFileChanges(url: (item?.url.path)!)
            } catch {
                Log.error("Error when trying to discard changes in file!")
            }
        }
    }

    @objc
    private func addSelectedFiles() {

    }
}

extension NSMenuItem {
    fileprivate static func none() -> NSMenuItem {
        let item = NSMenuItem(title: "<None>", action: nil, keyEquivalent: "")
        item.isEnabled = false
        return item
    }

    fileprivate static func propertyList() -> NSMenuItem {
        NSMenuItem(title: "Property List", action: nil, keyEquivalent: "")
    }

    fileprivate static func asciiPropertyList() -> NSMenuItem {
        NSMenuItem(title: "ASCII Property List", action: nil, keyEquivalent: "")
    }

    fileprivate static func hex() -> NSMenuItem {
        NSMenuItem(title: "Hex", action: nil, keyEquivalent: "")
    }

    fileprivate static func quickLook() -> NSMenuItem {
        NSMenuItem(title: "Quick Look", action: nil, keyEquivalent: "")
    }
}
