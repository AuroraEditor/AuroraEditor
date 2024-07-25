//
//  ProjectNavigatorOutlineDelegate.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 9/9/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

// MARK: - NSOutlineViewDelegate

extension ProjectNavigatorViewController: NSOutlineViewDelegate {
    /// Should show cell expansion for table column
    /// 
    /// - Parameter outlineView: the outline view
    /// 
    /// - Returns: whether to show cell expansion
    func outlineView(_ outlineView: NSOutlineView,
                     shouldShowCellExpansionFor tableColumn: NSTableColumn?,
                     item: Any) -> Bool {
        true
    }

    /// Should show cell outline for table column
    /// 
    /// - Parameter outlineView: the outline view
    /// - Parameter item: the item
    /// 
    /// - Returns: whether to show cell outline
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        true
    }

    /// View for table column
    /// 
    /// - Parameter outlineView: the outline view
    /// - Parameter tableColumn: the table column
    /// - Parameter item: the item
    /// 
    /// - Returns: the view
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {

        guard let tableColumn = tableColumn else { return nil }

        let frameRect = NSRect(x: 0, y: 0, width: tableColumn.width, height: rowHeight)

        return ProjectNavigatorTableViewCell(
            frame: frameRect,
            item: item as? Item,
            workspace: workspace
        )
    }

    /// Selection did change
    /// 
    /// - Parameter notification: notification
    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let workspace = workspace,
              let outlineView = notification.object as? NSOutlineView,
              let navigatorItem = outlineView.item(atRow: outlineView.selectedRow) as? Item else {
            return
        }

        // update the outlineview selection in the workspace. This is used by the bottom toolbar
        // when the + button is clicked to create a new file.
        workspace.newFileModel.outlineViewSelection = navigatorItem

        if !workspace.selectionState.openedTabs.contains(navigatorItem.tabID) &&
            !navigatorItem.isFolder && shouldSendSelectionUpdate {
            workspace.openTab(item: navigatorItem)
            self.logger.info("Opened a new tab for: \(navigatorItem.url)")
        }
    }

    /// Height of row by item
    /// 
    /// - Parameter outlineView: the outline view
    /// 
    /// - Returns: the height of the row
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        rowHeight // This can be changed to 20 to match Xcode's row height.
    }

    /// Outline view item did expand
    /// 
    /// - Parameter notification: notification
    func outlineViewItemDidExpand(_ notification: Notification) {
        updateSelection()
        saveExpansionState()
    }

    /// Outline view item did collapse
    /// 
    /// - Parameter notification: notification
    func outlineViewItemDidCollapse(_ notification: Notification) {
        saveExpansionState()
    }

    /// Item for persistent object
    /// 
    /// - Parameter outlineView: the outline view
    /// - Parameter object: the object
    /// 
    /// - Returns: the item
    func outlineView(_ outlineView: NSOutlineView, itemForPersistentObject object: Any) -> Any? {
        guard let id = object as? Item.ID,
              let item = try? workspace?.fileSystemClient?.getFileItem(id) else { return nil }

        return item
    }

    /// Persistent object for item
    /// 
    /// - Parameter outlineView: the outline view
    /// 
    /// - Returns: the persistent object
    func outlineView(_ outlineView: NSOutlineView, persistentObjectForItem item: Any?) -> Any? {
        guard let item = item as? Item else { return nil }

        return item.id
    }
}
