//
//  TabHierarchyOutlineDataSource.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 14/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

extension TabHierarchyViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard let workspace = workspace else { return 0 }
        if let item = item {
            // number of children for an item
            if let itemCategory = item as? TabHierarchyCategory { // if the item is a header
                switch itemCategory {
                case .savedTabs:
                    return workspace.selectionState.savedTabs.count ?? 0
                case .openTabs:
                    return workspace.selectionState.openedTabs.count ?? 0
                case .unknown:
                    break
                }
            } else if let item = item as? TabBarItemStorage {
                // the item is a tab. If it has children, return the children.
                return item.children.count
            }
        } else {
            // number of children in root view
            // one for the tabs in the hierarchy, one for the currently open tabs
            return 2
        }
        return 0
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard let workspace = workspace else { return 0 }

        // Top level, return the sections
        if item == nil {
            switch index {
            case 0:
                return TabHierarchyCategory.savedTabs
            case 1:
                return TabHierarchyCategory.openTabs
            default:
                return TabHierarchyCategory.unknown
            }

        // Secondary level, one layer down from the sections. Return the appropriate tabs.
        } else if let itemCategory = item as? TabHierarchyCategory {
            switch itemCategory {
            case .savedTabs:
                return workspace.selectionState.savedTabs[index]
            case .openTabs:
                return TabBarItemStorage(tabBarID: workspace.selectionState.openedTabs[index],
                                         category: .openTabs)
            case .unknown:
                break
            }

        // Other levels, one layer down from other tabs. Return the appropriate subtab.
        } else if let itemChildren = (item as? TabBarItemStorage)?.children {
            return itemChildren[index]
        }
        return 0
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        // if it is a header, return true
        if item is TabHierarchyCategory {
            return true

        // if it is a tab with children, return true
        } else if let item = item as? TabBarItemStorage, !item.children.isEmpty {
            return true

        // If it is anything else (eg. tab with no children), return false.
        } else {
            return false
        }
    }

    // MARK: Drag and Drop

    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        guard let item = item as? TabBarItemStorage else {
            Log.error("Item \(item) is not a tab storage item")
            return nil
        }

        // encode the item using jsonencoder
        let pboarditem = NSPasteboardItem()
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(item),
              let json = String(data: jsonData, encoding: String.Encoding.utf8) else { return nil }

        pboarditem.setString(json, forType: .string)
        return pboarditem
    }

    func outlineView(_ outlineView: NSOutlineView,
                     validateDrop info: NSDraggingInfo,
                     proposedItem item: Any?,
                     proposedChildIndex index: Int) -> NSDragOperation {

        // decode the data
        let jsonDecoder = JSONDecoder()
        guard let draggedData = info.draggingPasteboard.data(forType: .string),
              let recievedItem = try? jsonDecoder.decode(TabBarItemStorage.self, from: draggedData)
        else { return .deny}

        // Currently, only FileItem tabs are supported. This is because the rest of the tabs get de-init'd
        // when they get closed, meaning that the title for the tab gets bugged out.
        switch recievedItem.tabBarID {
        case .codeEditor:
            break
        default:
            return .deny
        }

        return .move
    }

    func outlineView(_ outlineView: NSOutlineView,
                     acceptDrop info: NSDraggingInfo,
                     item: Any?,
                     childIndex index: Int) -> Bool {

        let jsonDecoder = JSONDecoder()

        guard let draggedData = info.draggingPasteboard.data(forType: .string),
              let recievedItem = try? jsonDecoder.decode(TabBarItemStorage.self, from: draggedData)
        else { return false }

        guard self.outlineView(outlineView, validateDrop: info, proposedItem: item,
                               proposedChildIndex: index) == .move else { return false }

        // Remove the item from its old location
        if let recievedParentID = recievedItem.parentItem?.id {
            for tab in workspace?.selectionState.flattenedSavedTabs ?? [] where tab.id == recievedParentID {
                tab.children.removeAll(where: {
                    $0.id == recievedItem.id
                })
            }

        // if the item does not have a parent, it is a top level item
        } else {
            switch recievedItem.category {
            case .savedTabs:
                // remove the item from saved tabs
                workspace?.selectionState.savedTabs.removeAll(where: { $0.id == recievedItem.id })
            case .openTabs:
                // do not remove it from openTabs, as the user may want those tabs open.
                break
            case .unknown:
                return false
            }
        }

        return moveItemToNewLocation(item: recievedItem, to: item, at: index)
    }

    func moveItemToNewLocation(item recievedItem: TabBarItemStorage, to item: Any?, at index: Int) -> Bool {
        // Add the item to its new location
        if let destinationItem = item as? TabHierarchyCategory {
            switch destinationItem {
            case .savedTabs:
                recievedItem.category = .savedTabs
                recievedItem.parentItem = nil
                workspace?.selectionState.savedTabs.safeInsert(recievedItem, at: index)
            case .openTabs:
                // open the tab, do NOT insert it to avoid duplicates.
                if let itemTab = workspace?.selectionState.getItemByTab(id: recievedItem.tabBarID) {
                    workspace?.openTab(item: itemTab)
                } else {
                    return false
                }
            case .unknown:
                return false
            }
        } else if let destinationItem = item as? TabBarItemStorage {
            recievedItem.parentItem = destinationItem
            recievedItem.category = destinationItem.category
            destinationItem.children.safeInsert(recievedItem, at: index)
            outlineView.expandItem(destinationItem)
            outlineView.reloadData()
        }

        return true
    }
}

extension NSDragOperation {
    static let deny: NSDragOperation = NSDragOperation(arrayLiteral: [])
}

fileprivate extension Array {
    mutating func safeInsert(_ element: Self.Element, at index: Int) {
        if index >= 0 && index < count {
            self.insert(element, at: index)
        } else {
            self.append(element)
        }
    }
}
