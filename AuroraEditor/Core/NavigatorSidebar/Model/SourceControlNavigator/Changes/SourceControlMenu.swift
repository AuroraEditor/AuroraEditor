//
//  SourceControlMenu.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/10.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Version_Control

/// A `NSMenu` that displays source control options for a file.
final class SourceControlMenu: NSMenu {

    typealias Item = FileItem

    /// The git client for the workspace.
    private let gitClient: GitClient

    /// The item that the menu is for.
    var item: Item?

    /// The workspace document.
    var workspace: WorkspaceDocument?

    /// The file manager.
    private let fileManger = FileManager.default

    /// The outline view that the menu is for.
    private var outlineView: NSOutlineView

    /// Initialize the menu.
    /// 
    /// - Parameter sender: the outline view
    /// - Parameter workspaceURL: the workspace URL
    /// 
    /// - Returns: the menu
    init(sender: NSOutlineView, workspaceURL: URL) {
        outlineView = sender
        gitClient = GitClient(
            directoryURL: workspaceURL,
            shellClient: sharedShellClient.shellClient
        )
        super.init(title: "Source Control Options")
    }

    /// Initialize the menu.
    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Set the menu for a menu item.
    /// 
    /// - Parameter submenu: the menu
    /// - Parameter item: the item
    /// 
    /// - Returns: the menu item
    private func menuItem(_ title: String, action: Selector?, key: String = "") -> NSMenuItem {
        let mItem = NSMenuItem(title: title, action: action, keyEquivalent: key)
        mItem.target = self

        return mItem
    }

    /// Set the menu for a menu item.
    func setupMenu() {

        let showInFinder = menuItem("Show in Finder", action: #selector(showInFinder))
        let revealInProjectNav = menuItem("Reveal in Project Navigator", action: nil)

        let openInTab = menuItem("Open in Tab", action: #selector(openInTab))
        let openInNewWindow = menuItem("Open in New Indow", action: nil)
        let openExternalEditor = menuItem("Open with External Editor", action: #selector(openWithExternalEditor))
        let sourceControlRelatedMenu = SourceControlRelatedMenu(
            sender: outlineView,
            workspaceURL: gitClient.directoryURL
        )
        sourceControlRelatedMenu.item = item
        sourceControlRelatedMenu.setupMenu()

        let sourceControl = menuItem("Source Control", action: nil)
        setSubmenu(sourceControlRelatedMenu, for: sourceControl)
        items = [
            showInFinder,
            revealInProjectNav,
            NSMenuItem.separator(),
            openInTab,
            openInNewWindow,
            openExternalEditor,
            NSMenuItem.separator(),
            sourceControl
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

}

extension NSMenuItem {
    /// None menu item
    fileprivate static func none() -> NSMenuItem {
        let item = NSMenuItem(title: "<None>", action: nil, keyEquivalent: "")
        item.isEnabled = false
        return item
    }

    /// Property list menu item
    fileprivate static func propertyList() -> NSMenuItem {
        NSMenuItem(title: "Property List", action: nil, keyEquivalent: "")
    }

    /// ASCII property list menu item
    fileprivate static func asciiPropertyList() -> NSMenuItem {
        NSMenuItem(title: "ASCII Property List", action: nil, keyEquivalent: "")
    }

    /// Hex menu item
    fileprivate static func hex() -> NSMenuItem {
        NSMenuItem(title: "Hex", action: nil, keyEquivalent: "")
    }

    /// Quick Look menu item
    fileprivate static func quickLook() -> NSMenuItem {
        NSMenuItem(title: "Quick Look", action: nil, keyEquivalent: "")
    }
}
