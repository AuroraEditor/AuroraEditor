//
//  ProjectNavigatorOutlineDataSource.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 9/9/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

extension ProjectNavigatorViewController: NSOutlineViewDataSource {
    /// Returns the number of children for a given item.
    /// 
    /// - Parameter outlineView: the outline view
    /// - Parameter item: the item
    /// 
    /// - Returns: the number of children
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard let workspace = self.workspace else { return 0 }
        if let item = item as? Item {
            return item.appearanceWithinChildrenOf(searchString: workspace.filter)
        }

        return content.count
    }

    /// Returns the child for a given index.
    /// 
    /// - Parameter outlineView: the outline view
    /// - Parameter index: the index
    /// 
    /// - Returns: the child
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard let workspace = self.workspace,
              let item = item as? Item
        else { return content[index] }

        return item.childrenSatisfying(searchString: workspace.filter)[index]
    }

    /// Returns the object for a given item.
    /// 
    /// - Parameter outlineView: the outline view
    /// - Parameter item: the item
    /// 
    /// - Returns: the object
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let item = item as? Item {
            return item.children != nil
        }
        return false
    }

    // MARK: Drag and Drop

    /// Pasteboard writer for item
    /// 
    /// - Parameter outlineView: the outline view
    /// - Parameter item: the item
    /// 
    /// - Returns: the pasteboard writer
    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        guard let fileItem = item as? FileItem else {
            self.logger.fault("Item is not file item")
            return nil
        }
        let pboarditem = NSPasteboardItem()
        pboarditem.setString(fileItem.url.path, forType: dragType)
        return pboarditem
    }

    /// Validates the drop operation.
    /// 
    /// - Parameter outlineView: the outline view
    /// - Parameter info: the dragging info
    /// - Parameter item: the item
    /// - Parameter index: the index
    /// 
    /// - Returns: the drag operation
    func outlineView(_ outlineView: NSOutlineView,
                     validateDrop info: NSDraggingInfo,
                     proposedItem item: Any?,
                     proposedChildIndex index: Int) -> NSDragOperation {
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

    /// Accepts the drop operation.
    /// 
    /// - Parameter outlineView: the outline view
    /// - Parameter info: the dragging info
    /// - Parameter item: the item
    /// - Parameter index: the index
    /// 
    /// - Returns: a boolean indicating if the drop was successful
    func outlineView(_ outlineView: NSOutlineView,
                     acceptDrop info: NSDraggingInfo,
                     item: Any?,
                     childIndex index: Int) -> Bool {
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
            self.logger.fault("Moving item \(draggedURL) to \(targetFileItem.url) failed: \(error)")
            return false
        }
        return true
    }
}
