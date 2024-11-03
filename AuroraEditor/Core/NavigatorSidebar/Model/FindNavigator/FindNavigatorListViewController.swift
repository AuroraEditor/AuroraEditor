//
//  FindNavigatorListViewController.swift
//  Aurora Editor
//
//  Created by Khan Winter on 7/7/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A view controller that displays search results in a list view.
final class FindNavigatorListViewController: NSViewController {
    /// The workspace document
    public var workspace: WorkspaceDocument

    /// The selected item
    public var selectedItem: Any?

    typealias FileItem = FileSystemClient.FileItem

    /// The search ID
    private var searchId: UUID?

    /// The search items
    private var searchItems: [SearchResultModel] = []

    /// The scroll view
    private var scrollView: NSScrollView!

    /// The outline view
    private var outlineView: NSOutlineView!

    /// The application preferences
    private let prefs = AppPreferencesModel.shared.preferences

    /// The collapsed rows
    private var collapsedRows: Set<Int> = []

    /// The row height
    var rowHeight: Double = 22 {
        didSet {
            outlineView?.reloadData()
        }
    }

    /// Setup the `scrollView` and `outlineView`
    override func loadView() {
        self.scrollView = NSScrollView()
        self.view = scrollView

        outlineView = NSOutlineView()
        outlineView.dataSource = self
        outlineView.delegate = self
        outlineView.headerView = nil
        outlineView.lineBreakMode = .byTruncatingTail

        let column = NSTableColumn(identifier: .init(rawValue: "Cell"))
        column.title = "Cell"
        outlineView.addTableColumn(column)

        scrollView.documentView = outlineView
        scrollView.contentView.automaticallyAdjustsContentInsets = false
        scrollView.contentView.contentInsets = .init(top: 10, left: 0, bottom: 0, right: 0)
        scrollView.hasVerticalScroller = true
    }

    /// Initialize a new FindNavigatorListViewController
    /// 
    /// - Parameter workspace: the workspace document
    /// 
    /// - Returns: a new FindNavigatorListViewController
    init(workspace: WorkspaceDocument) {
        self.workspace = workspace
        super.init(nibName: nil, bundle: nil)
    }

    /// Initialize a new FindNavigatorListViewController
    /// 
    /// - Parameter coder: the coder
    /// 
    /// - Returns: a new FindNavigatorListViewController
    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) not implemented by FindNavigatorListViewController")
    }

    /// Accepts first responder
    override var acceptsFirstResponder: Bool { true }

    /// Sets the search items for the view without loading anything.
    /// 
    /// - Parameter searchItems: The search items to set.
    public func setSearchResults(_ searchItems: [SearchResultModel]) {
        self.searchItems = searchItems
    }

    /// Updates the view with new search results and updates the UI.
    /// 
    /// - Parameter searchItems: The search items to set.
    /// - Parameter searchText: The search text, used to preserve result deletions across view updates.
    @MainActor
    public func updateNewSearchResults(_ searchItems: [SearchResultModel], searchId: UUID?) {
        if searchId != self.searchId {
            self.searchItems = searchItems
            outlineView.reloadData()
            outlineView.expandItem(nil, expandChildren: true)

            self.searchId = searchId
        }

        if let selectedItem = selectedItem {
            selectSearchResult(selectedItem)
        }
    }

    /// Handles key up events
    /// 
    /// - Parameter event: the event
    override func keyUp(with event: NSEvent) {
        if event.charactersIgnoringModifiers == String(NSEvent.SpecialKey.delete.unicodeScalar) {
            deleteSelectedItem()
        }
        super.keyUp(with: event)
    }

    /// Removes the selected item, called in response to an action like the backspace
    /// character
    private func deleteSelectedItem() {
        let selectedRow = outlineView.selectedRow
        guard selectedRow >= 0,
              let selectedItem = outlineView.item(atRow: selectedRow) else { return }

        if selectedItem is SearchResultMatchModel {
            guard let parent = outlineView.parent(forItem: selectedItem) else { return }

            // Remove the item from the search results
            let parentIndex = outlineView.childIndex(forItem: parent)
            let childIndex = outlineView.childIndex(forItem: selectedItem)
            searchItems[parentIndex].lineMatches.remove(at: childIndex)

            // If this was the last child, we need to remove the parent or we'll
            // hit an exception
            if searchItems[parentIndex].lineMatches.isEmpty {
                searchItems.remove(at: parentIndex)
                outlineView.removeItems(at: IndexSet([parentIndex]), inParent: nil)
            } else {
                outlineView.removeItems(at: IndexSet([childIndex]), inParent: parent)
            }
        } else {
            let index = outlineView.childIndex(forItem: selectedItem)
            searchItems.remove(at: index)
            outlineView.removeItems(at: IndexSet([index]), inParent: nil)
        }

        outlineView.selectRowIndexes(IndexSet([selectedRow]), byExtendingSelection: false)
    }

    /// Selects a search result in the outline view
    /// 
    /// - Parameter selectedItem: The item to select.
    public func selectSearchResult(_ selectedItem: Any) {
        let index = outlineView.row(forItem: selectedItem)
        guard index >= 0 && index != outlineView.selectedRow else { return }
        outlineView.selectRowIndexes(IndexSet([index]), byExtendingSelection: false)
    }
}

// MARK: - NSOutlineViewDataSource

/// The NSOutlineViewDataSource implementation for FindNavigatorListViewController
extension FindNavigatorListViewController: NSOutlineViewDataSource {
    /// Returns the number of children for the given item.
    /// 
    /// - Parameter outlineView: The outline view.
    /// - Parameter item: The item to get the number of children for.
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let item = item as? SearchResultModel {
            return item.lineMatches.count
        }

        return searchItems.count
    }

    /// Returns the child at the given index for the given item.
    /// 
    /// - Parameter outlineView: The outline view.
    /// - Parameter index: The index of the child to get.
    /// - Parameter item: The item to get the child for.
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let item = item as? SearchResultModel {
            return item.lineMatches[index]
        }

        return searchItems[index]
    }

    /// Returns whether the given item is expandable.
    /// 
    /// - Parameter outlineView: The outline view.
    /// - Parameter item: The item to check.
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if item is SearchResultModel {
            return true
        }

        return false
    }
}

// MARK: - NSOutlineViewDelegate

/// The NSOutlineViewDelegate implementation for FindNavigatorListViewController
extension FindNavigatorListViewController: NSOutlineViewDelegate {
    /// Returns the view for the given table column and item.
    /// 
    /// - Parameter outlineView: The outline view.
    /// - Parameter tableColumn: The table column.
    /// - Parameter item: The item to get the view for.
    /// 
    /// - Returns: The view for the given table column and item.
    func outlineView(_ outlineView: NSOutlineView,
                     shouldShowCellExpansionFor tableColumn: NSTableColumn?,
                     item: Any) -> Bool {
        return item is SearchResultModel
    }

    /// Returns the view for the given table column and item.
    /// 
    /// - Parameter outlineView: The outline view.
    /// - Parameter tableColumn: The table column.
    /// - Parameter item: The item to get the view for.
    /// 
    /// - Returns: The view for the given table column and item.
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        true
    }

    /// Returns the view for the given table column and item.
    /// 
    /// - Parameter outlineView: The outline view.
    /// - Parameter tableColumn: The table column.
    /// - Parameter item: The item to get the view for.
    /// 
    /// - Returns: The view for the given table column and item.
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let tableColumn = tableColumn else { return nil }
        if let item = item as? SearchResultMatchModel {
            let frameRect = NSRect(x: 0, y: 0, width: tableColumn.width, height: CGFloat.greatestFiniteMagnitude)
            return FindNavigatorListMatchCell(frame: frameRect,
                                              matchItem: item)
        } else {
            let frameRect = NSRect(x: 0,
                                   y: 0,
                                   width: tableColumn.width,
                                   height: prefs.general.projectNavigatorSize.rowHeight)
            let view = ProjectNavigatorTableViewCell(
                frame: frameRect,
                item: (item as? SearchResultModel)?.file,
                workspace: workspace,
                isEditable: false
            )
            // We're using a medium label for file names b/c it makes it easier to
            // distinguish quickly which results are from which files.
            view.label.font = .systemFont(ofSize: 11, weight: .medium)
            return view
        }
    }

    /// Outline view selection did change
    /// 
    /// - Parameter notification: notification
    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let outlineView = notification.object as? NSOutlineView else {
            return
        }

        let selectedIndex = outlineView.selectedRow

        if let item = outlineView.item(atRow: selectedIndex) as? SearchResultMatchModel {
            let selectedMatch = self.selectedItem as? SearchResultMatchModel
            if selectedItem == nil || selectedMatch != item {
                self.selectedItem = item
                workspace.openTab(item: item.file)
            }
        } else if let item = outlineView.item(atRow: selectedIndex) as? SearchResultModel {
            let selectedFile = self.selectedItem as? SearchResultModel
            if selectedItem == nil || selectedFile != item {
                self.selectedItem = item
                workspace.openTab(item: item.file)
            }
        }
    }

    /// Returns the height of the row for the given item.
    /// 
    /// - Parameter outlineView: The outline view.
    /// - Parameter item: The item to get the row height for.
    /// 
    /// - Returns: The height of the row for the given item.
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        if let item = item as? SearchResultMatchModel {
            let tempView = NSTextField(wrappingLabelWithString: item.attributedLabel().string)
            tempView.allowsDefaultTighteningForTruncation = false
            tempView.cell?.truncatesLastVisibleLine = true
            tempView.cell?.wraps = true
            tempView.cell?.font = .labelFont(ofSize: 11)
            tempView.maximumNumberOfLines = 3
            tempView.attributedStringValue = item.attributedLabel()
            tempView.font = .labelFont(ofSize: 11)
            tempView.layout()
            let width = outlineView.frame.width - outlineView.indentationPerLevel * 2 - 24
            return tempView.sizeThatFits(NSSize(width: width,
                                                height: CGFloat.greatestFiniteMagnitude)).height + 8
        } else {
            return rowHeight
        }
    }

    /// Outline view column did resize
    /// 
    /// - Parameter notification: notification
    func outlineViewColumnDidResize(_ notification: Notification) {
        let indexes = IndexSet(integersIn: 0..<searchItems.count)
        outlineView.noteHeightOfRows(withIndexesChanged: indexes)
    }

}

// MARK: - NSMenuDelegate

/// The NSMenuDelegate implementation for FindNavigatorListViewController
extension FindNavigatorListViewController: NSMenuDelegate {

}
