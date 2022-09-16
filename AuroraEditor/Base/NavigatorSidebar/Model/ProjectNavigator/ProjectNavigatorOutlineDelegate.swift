//
//  ProjectNavigatorOutlineDelegate.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 9/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

// MARK: - NSOutlineViewDelegate

extension ProjectNavigatorViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView,
                     shouldShowCellExpansionFor tableColumn: NSTableColumn?, item: Any) -> Bool {
        true
    }

    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        true
    }

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {

        guard let tableColumn = tableColumn else { return nil }

        let frameRect = NSRect(x: 0, y: 0, width: tableColumn.width, height: rowHeight)

        return ProjectNavigatorTableViewCell(frame: frameRect, item: item as? Item)
    }

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
            Log.info("Opened a new tab for: \(navigatorItem.url)")
        }
    }

    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        rowHeight // This can be changed to 20 to match Xcode's row height.
    }

    func outlineViewItemDidExpand(_ notification: Notification) {
        updateSelection()
        saveExpansionState()
    }

    func outlineViewItemDidCollapse(_ notification: Notification) {
        saveExpansionState()
    }

    func outlineView(_ outlineView: NSOutlineView, itemForPersistentObject object: Any) -> Any? {
        guard let id = object as? Item.ID,
              let item = try? workspace?.fileSystemClient?.getFileItem(id) else { return nil }
        return item
    }

    func outlineView(_ outlineView: NSOutlineView, persistentObjectForItem item: Any?) -> Any? {
        guard let item = item as? Item else { return nil }
        return item.id
    }
}
