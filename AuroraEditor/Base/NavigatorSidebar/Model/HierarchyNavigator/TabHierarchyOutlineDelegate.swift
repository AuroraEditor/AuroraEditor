//
//  TabHierarchyOutlineDelegate.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 14/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

extension TabHierarchyViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView,
                     shouldShowCellExpansionFor tableColumn: NSTableColumn?, item: Any) -> Bool {
        true
    }

    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        true
    }

    func outlineView(_ outlineView: NSOutlineView,
                     viewFor tableColumn: NSTableColumn?,
                     item: Any) -> NSView? {
        guard let tableColumn = tableColumn else { return nil }

        let frameRect = NSRect(x: 0, y: 0, width: tableColumn.width, height: rowHeight)
        if let itemCategory = item as? TabHierarchyCategory { // header items
            var itemText = ""
            switch itemCategory {
            case .savedTabs:
                itemText = "Saved Tabs: \(workspace?.selectionState.savedTabs.allTabs ?? 0)"
            case .openTabs:
                itemText = "Open Tabs: \(workspace?.selectionState.openedTabs.count ?? 0)"
            case .unknown:
                itemText = "Unknown Category"
            }
            let textField = TextTableViewCell(frame: frameRect, isEditable: false, startingText: itemText)
            return textField
        } else if let itemTab = item as? TabBarItemStorage { // tab items
            let tabView = TabHierarchyTableViewCell(frame: frameRect)
            tabView.workspace = workspace
            tabView.addTabItem(tabItem: itemTab.tabBarID)
            return tabView
        }
        return nil
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
        // open the tab only on double click, not here.
    }

    // Do not allow a header to be selected
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        if item is TabHierarchyCategory {
            return false
        }
        return true
    }

    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        rowHeight // This can be changed to 20 to match Xcode's row height.
    }

    func outlineView(_ outlineView: NSOutlineView, itemForPersistentObject object: Any) -> Any? {
        return nil
    }

    func outlineView(_ outlineView: NSOutlineView, persistentObjectForItem item: Any?) -> Any? {
        return nil
    }
}

// MARK: Right-click menu
extension TabHierarchyViewController: NSMenuDelegate {

    /// Once a menu gets requested by a `right click` setup the menu
    ///
    /// If the right click happened outside a row this will result in no menu being shown.
    /// - Parameter menu: The menu that got requested
    func menuNeedsUpdate(_ menu: NSMenu) {
        let row = outlineView.clickedRow
        guard let menu = menu as? TabHierarchyMenu else { return }

        if row != -1 {
            menu.workspace = workspace
            menu.item = outlineView.item(atRow: row)
        }
        menu.update()
    }
}
