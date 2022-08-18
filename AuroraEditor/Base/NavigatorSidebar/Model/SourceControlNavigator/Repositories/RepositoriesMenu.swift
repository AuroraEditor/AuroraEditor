//
//  RepositoriesMenu.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 17/8/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

/// A subclass of `NSMenu` implementing the contextual menu for the project navigator
final class RepositoriesMenu: NSMenu {
    typealias Item = WorkspaceClient.FileItem

    /// The workspace, for opening the item
    var workspace: WorkspaceDocument?

    var repository: DummyRepo?

    private let fileManger = FileManager.default

    var outlineView: NSOutlineView

    init(sender: NSOutlineView, workspaceURL: URL) {
        outlineView = sender
        super.init(title: "Options")
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Creates a `NSMenuItem` depending on the given arguments
    /// - Parameters:
    ///   - title: The title of the menu item
    ///   - action: A `Selector` or `nil` of the action to perform.
    ///   - key: A `keyEquivalent` of the menu item. Defaults to an empty `String`
    /// - Returns: A `NSMenuItem` which has the target `self`
    private func menuItem(_ title: String, action: Selector?, key: String = "") -> NSMenuItem {
        let mItem = NSMenuItem(title: title, action: action, keyEquivalent: key)
        mItem.target = self

        return mItem
    }

    /// Setup the menu and disables certain items when `isFile` is false
    /// - Parameter isFile: A flag indicating that the item is a file instead of a directory
    private func setupMenu() {

        items = [
            menuItem("New Branch from [selected branch name]", action: nil),
            menuItem("Rename [selected branch name]", action: nil),
            menuItem("Tag [selected branch name]", action: nil),
            menuItem("Switch...", action: nil),
            NSMenuItem.separator(),
            menuItem("Merge from Branch...", action: nil),
            menuItem("Merge into Branch...", action: nil),
            NSMenuItem.separator(),
            menuItem("New \"\(repository?.repoName ?? "Unknown Repository")\" Remote...", action: nil),
            menuItem("Add Existing Remote...", action: nil),
            NSMenuItem.separator(),
            menuItem("View on [Remote Provider]", action: nil),
            menuItem("Apply Stashed Changes...", action: nil),
            menuItem("Export Stashed Changes as Patch File...", action: nil),
            NSMenuItem.separator(),
            menuItem("Delete", action: nil)
        ]
    }

    /// Updates the menu for the selected item and hides it if no item is provided.
    override func update() {
        removeAllItems()
        setupMenu()
    }
}
