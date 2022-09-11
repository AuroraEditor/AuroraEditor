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

    // TODO: Change item to a specific type
    var item: Any?

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
            menuItem("Open Item", action: nil),
            menuItem("Remove Item", action: nil)
        ]
    }

    /// Updates the menu for the selected item and hides it if no item is provided.
    override func update() {
        removeAllItems()
        setupMenu()
    }
}
