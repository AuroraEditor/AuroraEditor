//
//  TabHierarchyMenu.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 11/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

/// A subclass of `NSMenu` implementing the contextual menu for the project navigator
final class TabHierarchyMenu: NSMenu {

    /// The workspace, for opening the item
    var workspace: WorkspaceDocument?

    var outlineView: NSOutlineView

    var item: TabBarItemStorage?

    init(sender: NSOutlineView) {
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
            menuItem("Open Item", action: #selector(openItem)),
            menuItem("Remove Item", action: #selector(deleteItem))
        ]
    }

    /// Updates the menu for the selected item and hides it if no item is provided.
    override func update() {
        removeAllItems()
        setupMenu()
    }

    @objc
    func openItem() {
        guard let item = item,
              let itemTab = workspace?.selectionState.getItemByTab(id: item.tabBarID) else { return }
        DispatchQueue.main.async {
            self.workspace?.openTab(item: itemTab)
        }
    }

    @objc
    func deleteItem() {
        guard let item = item else { return }
        // Remove the item from its old location
        if let recievedParentID = item.parentItem?.id {
            for tab in workspace?.selectionState.flattenedSavedTabs ?? [] where tab.id == recievedParentID {
                tab.children.removeAll(where: {
                    $0.id == item.id
                })
            }

        // if the item does not have a parent, it is a top level item
        } else {
            switch item.category {
            case .savedTabs:
                // remove the item from saved tabs
                workspace?.selectionState.savedTabs.removeAll(where: { $0.id == item.id })
            case .openTabs:
                // do not remove it from openTabs, as the user may want those tabs open.
                break
            case .unknown:
                return
            }
        }

        outlineView.reloadData()
    }
}
