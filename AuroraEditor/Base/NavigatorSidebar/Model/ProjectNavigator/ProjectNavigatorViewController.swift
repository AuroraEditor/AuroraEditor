//
//  OutlineViewController.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 07.04.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Combine

/// A `NSViewController` that handles the **ProjectNavigator** in the **NavigatorSideabr**.
///
/// Adds a ``outlineView`` inside a ``scrollView`` which shows the folder structure of the
/// currently open project.
final class ProjectNavigatorViewController: NSViewController {

    typealias Item = FileSystemClient.FileItem
    let dragType: NSPasteboard.PasteboardType = .fileURL

    @ObservedObject
    var prefs: AppPreferencesModel = .shared

    var scrollView: NSScrollView!
    var outlineView: NSOutlineView!

    var cancelables: Set<AnyCancellable> = .init()

    /// Gets the folder structure
    ///
    /// Also creates a top level item "root" which represents the projects root directory and automatically expands it.
    var content: [Item] {
        guard let folderURL = workspace?.fileSystemClient?.folderURL else { return [] }
        let children = workspace?.fileItems.sortItems(foldersOnTop: true)
        guard let root = try? workspace?.fileSystemClient?.getFileItem(folderURL.path) else { return [] }
        root.children = children
        return [root]
    }

    var workspace: WorkspaceDocument?

    var iconColor: AppPreferences.FileIconStyle = .color
    var fileExtensionsVisibility: AppPreferences.FileExtensionsVisibility = .showAll
    var shownFileExtensions: AppPreferences.FileExtensions = .default
    var hiddenFileExtensions: AppPreferences.FileExtensions = .default

    var rowHeight: Double = 22 {
        didSet {
            outlineView.rowHeight = rowHeight
            outlineView.reloadData()
        }
    }

    /// This helps determine whether or not to send an `openTab` when the selection changes.
    /// Used b/c the state may update when the selection changes, but we don't necessarily want
    /// to open the file a second time.
    var shouldSendSelectionUpdate: Bool = true

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
        outlineView.menu = ProjectNavigatorMenu(sender: self.outlineView, workspaceURL: (workspace?.fileURL)!)
        outlineView.menu?.delegate = self
        outlineView.doubleAction = #selector(onItemDoubleClicked)

        let column = NSTableColumn(identifier: .init(rawValue: "Cell"))
        column.title = "Cell"
        outlineView.addTableColumn(column)

        scrollView.documentView = outlineView
        scrollView.contentView.automaticallyAdjustsContentInsets = false
        scrollView.contentView.contentInsets = .init(top: 10, left: 0, bottom: 0, right: 0)
        scrollView.scrollerStyle = .overlay
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        outlineView.registerForDraggedTypes([dragType])

        outlineView.expandItem(outlineView.item(atRow: 0))
        saveExpansionState()
        reloadChangedFiles()

        workspace?.broadcaster.broadcaster.sink(receiveValue: recieveCommand).store(in: &cancelables)
    }

    func recieveCommand(command: AuroraCommandBroadcaster.Broadcast) {
        switch command.name {
        case "newFileAtPos":
            guard let item = self.outlineView.item(atRow: self.outlineView.selectedRow) as? FileItem
            else { return }

            Log.info("Created file at \(item.url.debugDescription)")
            item.addFile(fileName: "untitled")
        case "newDirAtPos":
            guard let item = self.outlineView.item(atRow: self.outlineView.selectedRow) as? FileItem
            else { return }
            Log.info("Created folder at \(item.url.debugDescription)")
            item.addFolder(folderName: "untitled")
        default: break
        }
    }

    override func viewDidDisappear() {
        cancelables.forEach({ $0.cancel() })
    }

    func reloadChangedFiles() {
        if let model = workspace?.fileSystemClient?.model, let wsClient = workspace?.fileSystemClient {
            for item in model.reloadChangedFiles() {
                outlineView.reloadItem(try? wsClient.getFileItem(item.id))
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: { self.reloadChangedFiles() })
        }
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
    func updateSelection() {
        guard let itemID = workspace?.selectionState.selectedId else {
            outlineView.deselectRow(outlineView.selectedRow)
            return
        }

        select(by: itemID, from: content)
    }

    /// Expand or collapse the folder on double click
    @objc
    private func onItemDoubleClicked() {
        guard let item = outlineView.item(atRow: outlineView.clickedRow) as? Item else { return }

        if item.children != nil {
            if outlineView.isItemExpanded(item) {
                outlineView.collapseItem(item)
            } else {
                outlineView.expandItem(item)
            }
        } else {
            if workspace?.selectionState.temporaryTab == item.tabID {
                workspace?.convertTemporaryTab()
            }
        }
    }

    /// Get the appropriate color for the items icon depending on the users preferences.
    /// - Parameter item: The `FileItem` to get the color for
    /// - Returns: A `NSColor` for the given `FileItem`.
    private func color(for item: Item) -> NSColor {
        if item.children == nil && iconColor == .color {
            return NSColor(item.iconColor)
        } else {
            return .secondaryLabelColor
        }
    }

    private var isExpandingThings: Bool = false
    /// Perform functions related to reloading the Outline View
    func reloadData() {
        self.outlineView.reloadData()
        guard let workspace = self.workspace else { return }
        if !workspace.filter.isEmpty {
            // expand everything
            outlineView.expandItem(outlineView.item(atRow: 0), expandChildren: true)
        } else {
            loadExpansionState()
        }
    }

    /// Save the expansion state of the items in the Project Navigator
    func saveExpansionState() {
        guard let workspace = self.workspace,
              let workspaceItem = outlineView.item(atRow: 0) as? Item,
              workspace.filter.isEmpty && !isExpandingThings else { return }
        saveExpansionState(of: workspaceItem)
    }

    func saveExpansionState(of item: Item) {
        item.shouldBeExpanded = outlineView.isItemExpanded(item)
        guard item.shouldBeExpanded else { return }
        for childIndex in 0 ..< outlineView.numberOfChildren(ofItem: item) {
            guard let child = outlineView.child(childIndex, ofItem: item) as? Item else { return }
            guard child.shouldBeExpanded != outlineView.isItemExpanded(child) else { continue }
            child.shouldBeExpanded = outlineView.isItemExpanded(child)
            if outlineView.isItemExpanded(child) {
                saveExpansionState(of: child)
            }
        }
    }

    /// Load any saved expansion state of the items in the Project Navigator
    func loadExpansionState() {
        isExpandingThings = true
        var rowNumber = 0
        while let itemToCheck = outlineView.item(atRow: rowNumber) {
            guard let fileItem = itemToCheck as? Item else { break }
            if fileItem.shouldBeExpanded {
                outlineView.expandItem(itemToCheck)
            } else {
                outlineView.collapseItem(itemToCheck)
            }
            rowNumber += 1
        }
        isExpandingThings = false
    }

    /// Recursively gets and selects an ``Item`` from an array of ``Item`` and their `children` based on the `id`.
    /// - Parameters:
    ///   - id: the id of the item item
    ///   - collection: the array to search for
    private func select(by id: TabBarItemID, from collection: [Item]) {
        // If the user has set "Reveal file on selection change" to on, we need to reveal the item before
        // selecting the row.
        if AppPreferencesModel.shared.preferences.general.revealFileOnFocusChange,
           case let .codeEditor(id) = id,
           let fileItem = try? workspace?.fileSystemClient?.getFileItem(id as Item.ID) as? Item {
            reveal(fileItem)
        }

        guard let item = collection.first(where: { $0.tabID == id }) else {
            for item in collection {
                select(by: id, from: item.children ?? [])
            }
            return
        }
        let row = outlineView.row(forItem: item)
        if row == -1 {
            outlineView.deselectRow(outlineView.selectedRow)
        }
        shouldSendSelectionUpdate = false
        outlineView.selectRowIndexes(.init(integer: row), byExtendingSelection: false)
        shouldSendSelectionUpdate = true
    }

    /// Reveals the given `fileItem` in the outline view by expanding all the parent directories of the file.
    /// If the file is not found, it will present an alert saying so.
    /// - Parameter fileItem: The file to reveal.
    public func reveal(_ fileItem: Item) {
        if let parent = fileItem.parent {
            expandParent(item: parent)
        }
        let row = outlineView.row(forItem: fileItem)
        outlineView.selectRowIndexes(.init(integer: row), byExtendingSelection: false)

        if row < 0 {
            let alert = NSAlert()
            alert.messageText = NSLocalizedString("Could not find file",
                                                  comment: "Could not find file")
            alert.runModal()
            return
        } else {
            outlineView.scrollRowToVisible(row)
        }
    }

    /// Method for recursively expanding a file's parent directories.
    /// - Parameter item:
    private func expandParent(item: Item) {
        if let parent = item.parent as Item? {
            expandParent(item: parent)
        }
        outlineView.expandItem(item)
    }
}

// MARK: Right-click menu
extension ProjectNavigatorViewController: NSMenuDelegate {

    /// Once a menu gets requested by a `right click` setup the menu
    ///
    /// If the right click happened outside a row this will result in no menu being shown.
    /// - Parameter menu: The menu that got requested
    func menuNeedsUpdate(_ menu: NSMenu) {
        let row = outlineView.clickedRow
        guard let menu = menu as? ProjectNavigatorMenu else { return }

        if row == -1 {
            menu.item = nil
        } else {
            if let item = outlineView.item(atRow: row) as? Item {
                menu.item = item
                menu.workspace = workspace
            } else {
                menu.item = nil
            }
        }
        menu.update()
    }
}
