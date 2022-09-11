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

        outlineView.expandItem(outlineView.item(atRow: 0))
        outlineView.expandItem(outlineView.item(atRow: 1))
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    /// Updates the selection of the ``outlineView`` whenever it changes.
    ///
    /// Most importantly when the `id` changes from an external view.
    // TODO: Selection
    func updateSelection() {
//        guard let itemID = workspace?.selectionState.selectedId else {
//            outlineView.deselectRow(outlineView.selectedRow)
//            return
//        }
//
//        select(by: itemID, from: content)
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
                    return 0
                case .openTabs:
                    return workspace?.selectionState.openedTabs.count ?? 0
                case .unknown:
                    return 0
                }
            } else {
                // the child is a tab. In the future might want to support nested tabs.
                return 0
            }
        } else {
            // number of children in root view
            // one for the tabs in the hierarchy, one for the currently open tabs
            return 2
        }
    }

    // TODO: Return the child at index of item
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            switch index {
            case 0:
                return TabHierarchyCategory.savedTabs
            case 1:
                return TabHierarchyCategory.openTabs
            default:
                return TabHierarchyCategory.unknown
            }
        } else if let itemCategory = item as? TabHierarchyCategory {
            // TODO: return the appropriate tab
            switch itemCategory {
            case .savedTabs:
                break
            case .openTabs:
                if let itemTab = workspace?.selectionState.openedTabs[index] {
                    return itemTab
                }
            case .unknown:
                break
            }
        }
        return 0
    }

    // TODO: Return if a certain item is expandable
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if item is TabHierarchyCategory { // if it is a header, return true
            return true
        } else {
            return false
        }
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
                itemText = "Saved Tabs: 0"
            case .openTabs:
                itemText = "Open Tabs: \(workspace?.selectionState.openedTabs.count ?? 0)"
            case .unknown:
                itemText = "Unknown Category"
            }
            let textField = TextTableViewCell(frame: frameRect, isEditable: false, startingText: itemText)
            return textField
        } else if let itemTab = item as? TabBarItemID { // tab items
            let textField = TextTableViewCell(frame: frameRect, isEditable: false, startingText: itemTab.id)
            return textField
        }
        return nil
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
        // let selectedIndex = outlineView.selectedRow
        // guard let item = outlineView.item(atRow: selectedIndex) else { return }
        // TODO: When the selection changes, most likely open the tab
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

enum TabHierarchyCategory {
    case savedTabs
    case openTabs
    case unknown
}
