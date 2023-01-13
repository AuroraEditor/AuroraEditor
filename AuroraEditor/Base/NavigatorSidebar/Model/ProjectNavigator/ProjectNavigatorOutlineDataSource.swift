//
//  ProjectNavigatorOutlineDataSource.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 9/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

extension ProjectNavigatorViewController: NSOutlineViewDataSource {

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard let workspace = self.workspace else { return 0 }
        if let item = item as? Item {
            return item.appearanceWithinChildrenOf(searchString: workspace.filter,
                                                   ignoredStrings: prefs.preferences.general.hiddenFilesAndFolders)
        }
        return content.count
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard let workspace = self.workspace,
              let item = item as? Item
        else { return content[index] }

        return item.childrenSatisfying(searchString: workspace.filter,
                                       ignoredStrings: prefs.preferences.general.hiddenFilesAndFolders)[index]
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let item = item as? Item {
            return item.children != nil
        }
        return false
    }

    // MARK: Drag and Drop
    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        guard let fileItem = item as? FileItem else {
            Log.error("Item \(item) is not file item")
            return nil
        }
        let pboarditem = NSPasteboardItem()
        pboarditem.setString(fileItem.url.path, forType: dragType)
        return pboarditem
    }

    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo,
                     proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        guard let targetFileItem = item as? FileItem,
              let draggedString = info.draggingPasteboard.string(forType: dragType)
        else { return NSDragOperation(arrayLiteral: [])}
        let draggedURL = URL(fileURLWithPath: draggedString)

        // if the item is being dragged onto an item that it contains, do not move it.

        // the target must be a folder
        // the target must not be within the dragged url
        // the target's url and dragged url's parent must differ
        guard targetFileItem.isFolder &&
              !targetFileItem.url.path.hasPrefix(draggedString) &&
              draggedURL.deletingLastPathComponent() != targetFileItem.url
        else { return NSDragOperation(arrayLiteral: []) }

        return NSDragOperation.move
    }

    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo,
                     item: Any?, childIndex index: Int) -> Bool {
        // just reuse the validation function to check if the drop should happen
        guard self.outlineView(outlineView, validateDrop: info,
                               proposedItem: item, proposedChildIndex: index) == .move,
              let targetFileItem = item as? FileItem,
              let draggedString = info.draggingPasteboard.string(forType: dragType)
        else { return false }
        let draggedURL = URL(fileURLWithPath: draggedString)
        do {
            let fileName = draggedURL.lastPathComponent
            try FileManager.default.moveItem(at: draggedURL, to: targetFileItem.url.appendingPathComponent(fileName))
        } catch {
            Log.error("Moving item \(draggedURL) to \(targetFileItem.url) failed: \(error)")
            return false
        }
        return true
    }
}
