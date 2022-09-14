//
//  TabHierarchyViewController.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 11/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

/// A `NSViewController` that handles the **Tab Heirarchy View** in the **Hierarchy Navigator**.
///
/// Adds a ``outlineView`` inside a ``scrollView`` which shows the user-created tab hierarchy of the
/// currently open project, similar to Orion Browser's vertical tabs.
class TabHierarchyViewController: NSViewController {
    var scrollView: NSScrollView!
    var outlineView: NSOutlineView!

    var workspace: WorkspaceDocument?

    var rowHeight: Double = 22 {
        didSet {
            outlineView.rowHeight = rowHeight
            outlineView.reloadData()
        }
    }

    /// This helps determine whether or not to send an `openTab` when the selection changes.
    /// Used b/c the state may update when the selection changes, but we don't necessarily want
    /// to open the file a second time.
    private var shouldSendSelectionUpdate: Bool = true

    /// Setup the ``scrollView`` and ``outlineView``
    override func loadView() {
        self.scrollView = NSScrollView()
        self.view = scrollView

        self.outlineView = NSOutlineView()
        outlineView.dataSource = self
        outlineView.delegate = self
        outlineView.autosaveExpandedItems = true
        outlineView.autosaveName = workspace?.fileSystemClient?.folderURL?.path ?? ""
        outlineView.headerView = nil
        outlineView.menu = RepositoriesMenu(sender: self.outlineView, workspaceURL: (workspace?.fileURL)!)
        outlineView.menu?.delegate = self
        outlineView.doubleAction = #selector(onItemDoubleClicked)

        let column = NSTableColumn(identifier: .init(rawValue: "Cell"))
        column.title = "Cell"
        outlineView.addTableColumn(column)

        scrollView.documentView = outlineView
        scrollView.contentView.automaticallyAdjustsContentInsets = false
        scrollView.contentView.contentInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
        scrollView.hasVerticalScroller = true
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        outlineView.registerForDraggedTypes([.string])

        outlineView.expandItem(outlineView.item(atRow: 0))
        outlineView.expandItem(outlineView.item(atRow: 1))
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    /// Expand or collapse the folder on double click
    // TODO: Double click stuff
    @objc
    private func onItemDoubleClicked() {
//        let item = outlineView.item(atRow: outlineView.clickedRow)
        // TODO: Expand or collapse tab item if possible
    }
}

// MARK: - NSOutlineViewDataSource

extension TabHierarchyViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        // TODO: Number of children
        if let item = item {
            // number of children for an item
            if let itemCategory = item as? TabHierarchyCategory { // if the item is a header
                switch itemCategory {
                case .savedTabs:
                    return workspace?.selectionState.savedTabs.count ?? 0
                case .openTabs:
                    return workspace?.selectionState.openedTabs.count ?? 0
                case .unknown:
                    break
                }
            } else if let item = item as? TabBarItemStorage {
                // the item is a tab. If it has children, return the children.
                return item.children?.count ?? 0
            }
        } else {
            // number of children in root view
            // one for the tabs in the hierarchy, one for the currently open tabs
            return 2
        }
        return 0
    }

    // TODO: Return the child at index of item
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
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
            // TODO: return the appropriate tab
            switch itemCategory {
            case .savedTabs:
                if let itemStorage = workspace?.selectionState.savedTabs[index] {
                    return itemStorage
                }
            case .openTabs:
                if let itemTab = workspace?.selectionState.openedTabs[index] {
                    return TabBarItemStorage(tabBarID: itemTab, category: .openTabs)
                }
            case .unknown:
                break
            }

        // Other levels, one layer down from other tabs. Return the appropriate subtab.
        } else if let itemChildren = (item as? TabBarItemStorage)?.children {
            return itemChildren[index]
        }
        return 0
    }

    // TODO: Return if a certain item is expandable
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        // if it is a header, return true
        if item is TabHierarchyCategory {
            return true

        // if it is a tab with children, return true
        } else if let item = item as? TabBarItemStorage, item.children != nil {
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

    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo,
                     proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {

        let jsonDecoder = JSONDecoder()

        guard let draggedData = info.draggingPasteboard.data(forType: .string),
              (try? jsonDecoder.decode(TabBarItemStorage.self, from: draggedData)) != nil
              else { return NSDragOperation(arrayLiteral: [])}

        return NSDragOperation.move
    }

    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo,
                     item: Any?, childIndex index: Int) -> Bool {

        let jsonDecoder = JSONDecoder()

        guard let draggedData = info.draggingPasteboard.data(forType: .string),
              let recievedItem = try? jsonDecoder.decode(TabBarItemStorage.self, from: draggedData)
              else { return false }

        // Get the ID string
        var idString = recievedItem.tabBarID.id
        if let underscoreRange = idString.range(of: "_") {
            idString.removeSubrange(underscoreRange.lowerBound..<idString.endIndex)
        }

        // Currently only FileItems work with the tab hierarchy view. This is because when tabs close,
        // they get removed and de-init'd, which causes the item's title to go haywire.
        if !recievedItem.tabBarID.id.hasPrefix("codeEditor") {
            Log.error("\(idString) not supported")
            return false
        }

        Log.info("Recieved item: \(recievedItem.tabBarID)")

        if let item = item as? TabHierarchyCategory {
            switch item {
            case .savedTabs:
                if index >= 0 {
                    workspace?.selectionState.savedTabs.insert(recievedItem, at: index)
                } else {
                    workspace?.selectionState.savedTabs.append(recievedItem)
                }
            case .openTabs:
                guard let itemTab = workspace?.selectionState
                    .getItemByTab(id: recievedItem.tabBarID) else { return false }
                workspace?.openTab(item: itemTab)
            case .unknown:
                break
            }
        } else if let item = item as? TabBarItemStorage {
            if item.children != nil && index >= 0 {
                item.children?.insert(recievedItem, at: index)
            } else {
                item.children = [recievedItem]
                outlineView.reloadItem(item)
                outlineView.expandItem(item)
            }
        }

        return true
    }
}

// MARK: - NSOutlineViewDelegate

extension TabHierarchyViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView,
                     shouldShowCellExpansionFor tableColumn: NSTableColumn?, item: Any) -> Bool {
        true
    }

    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        true
    }

    // TODO: View for item
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
        let selectedIndex = outlineView.selectedRow
        guard let item = outlineView.item(atRow: selectedIndex) as? TabBarItemStorage,
              let itemTab = workspace?.selectionState.getItemByTab(id: item.tabBarID) else { return }
        workspace?.openTab(item: itemTab)
    }

    // TODO: Don't allow selecting a header
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        if item is TabHierarchyCategory {
            return false
        }
        return true
    }

    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        rowHeight // This can be changed to 20 to match Xcode's row height.
    }

    // TODO: Return item for persistent object
    func outlineView(_ outlineView: NSOutlineView, itemForPersistentObject object: Any) -> Any? {
        return nil
//        guard let id = object as? Item.ID,
//              let item = try? workspace?.fileSystemClient?.getFileItem(id) else { return nil }
//        return item
    }

    // TODO: Return object for persistent item
    func outlineView(_ outlineView: NSOutlineView, persistentObjectForItem item: Any?) -> Any? {
        return nil
//        guard let item = item as? Item else { return nil }
//        return item.id
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
