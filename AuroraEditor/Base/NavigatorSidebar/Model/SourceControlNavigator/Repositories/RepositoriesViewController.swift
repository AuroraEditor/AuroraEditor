//
//  RepositoriesViewController.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 17/8/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

/// A `NSViewController` that handles the **Repositories View** in the **Source Control Navigator**.
///
/// Adds a ``outlineView`` inside a ``scrollView`` which shows the folder structure of the
/// currently open project.
final class RepositoriesViewController: NSViewController {

    var repository: DummyRepo!

    var scrollView: NSScrollView!
    var outlineView: NSOutlineView!

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
    private var shouldSendSelectionUpdate: Bool = true

    /// Setup the ``scrollView`` and ``outlineView``
    override func loadView() {
        self.scrollView = NSScrollView()
        self.view = scrollView

        self.outlineView = NSOutlineView()
        self.outlineView.dataSource = self
        self.outlineView.delegate = self
        self.outlineView.autosaveExpandedItems = true
        self.outlineView.autosaveName = workspace?.workspaceClient?.folderURL?.path ?? ""
        self.outlineView.headerView = nil
        self.outlineView.menu = RepositoriesMenu(sender: self.outlineView, workspaceURL: (workspace?.fileURL)!)
        self.outlineView.menu?.delegate = self
        self.outlineView.doubleAction = #selector(onItemDoubleClicked)

        let column = NSTableColumn(identifier: .init(rawValue: "Cell"))
        column.title = "Cell"
        outlineView.addTableColumn(column)

        self.scrollView.documentView = outlineView
        self.scrollView.contentView.automaticallyAdjustsContentInsets = false
        self.scrollView.contentView.contentInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
        scrollView.hasVerticalScroller = true

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
        let item = outlineView.item(atRow: outlineView.clickedRow)

        if item is DummyRepo || item is DummyContainer {
            if outlineView.isItemExpanded(item) {
                outlineView.collapseItem(item)
            } else {
                outlineView.expandItem(item)
            }
        }
    }
}

// MARK: - NSOutlineViewDataSource

extension RepositoriesViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item is DummyRepo {
            // item is a repo
            return 5
        } else if let item = item as? DummyContainer {
            // item is a container
            return item.contents.count
        } else if item is DummyItem {
            // item is an item, and therefore has no children
            return 0
        }
        // it might be the top level item, return 1 for the repo
        return 1
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let item = item as? DummyRepo {
            // item is a repo.
            switch index {
            case 0:
                return item.branches!
            case 1:
                return item.recentLocations!
            case 2:
                return item.tags!
            case 3:
                return item.stashedChanges!
            case 4:
                return item.remotes!
            default:
                return 0
            }
        } else if let item = item as? DummyContainer {
            // item is a container
            return item.contents[index]
        } else if item is DummyItem {
            // item is an item, has no children
            return 0
        }
        // item is top level, should be the repository
        if let repository = repository {
            return repository
        }
        return 0
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        // only repos and containers are expandable
        return item is DummyRepo || item is DummyContainer
    }
}

// MARK: - NSOutlineViewDelegate

extension RepositoriesViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView,
                     shouldShowCellExpansionFor tableColumn: NSTableColumn?, item: Any) -> Bool {
        true
    }

    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        true
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func outlineView(_ outlineView: NSOutlineView,
                     viewFor tableColumn: NSTableColumn?,
                     item: Any) -> NSView? {
        guard let tableColumn = tableColumn else { return nil }

        let frameRect = NSRect(x: 0, y: 0, width: tableColumn.width, height: rowHeight)

        if let item = item as? DummyRepo {
            // item is a repo.
            return RepositoriesTableViewCell(frame: frameRect,
                                             repository: item,
                                             represents: .repo)
        } else if let item = item as? DummyContainer {
            // item is a container
            if item is DummyBranches {
                return RepositoriesTableViewCell(frame: frameRect,
                                                 repository: repository,
                                                 represents: .branches)
            } else if item is DummyRecentLocations {
                return RepositoriesTableViewCell(frame: frameRect,
                                                 repository: repository,
                                                 represents: .recentLocations)
            } else if item is DummyStashedChanges {
                return RepositoriesTableViewCell(frame: frameRect,
                                                 repository: repository,
                                                 represents: .stashedChanges)
            } else if item is DummyTags {
                return RepositoriesTableViewCell(frame: frameRect,
                                                 repository: repository,
                                                 represents: .tags)
            } else if item is DummyRemotes {
                return RepositoriesTableViewCell(frame: frameRect,
                                                 repository: repository,
                                                 represents: .remotes)
            } else if item is DummyRemote {
                return RepositoriesTableViewCell(frame: frameRect,
                                                 repository: repository,
                                                 represents: .remote)
            }
        } else if let item = item as? DummyItem {
            if item is DummyBranch {
                return RepositoriesTableViewCell(frame: frameRect,
                                                 repository: repository,
                                                 represents: .branch,
                                                 item: item)
            } else if item is DummyTag {
                return RepositoriesTableViewCell(frame: frameRect,
                                                 repository: repository,
                                                 represents: .tag,
                                                 item: item)
            } else if item is DummyChange {
                return RepositoriesTableViewCell(frame: frameRect,
                                                 repository: repository,
                                                 represents: .change,
                                                 item: item)
            }
        }
        return nil
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
//        let selectedIndex = outlineView.selectedRow
        // TODO: If the item clicked is something openable (eg. a branch), open a tab
    }

    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        rowHeight // This can be changed to 20 to match Xcode's row height.
    }

    // TODO: Return item for persistent object
    func outlineView(_ outlineView: NSOutlineView, itemForPersistentObject object: Any) -> Any? {
        return nil
//        guard let id = object as? Item.ID,
//              let item = try? workspace?.workspaceClient?.getFileItem(id) else { return nil }
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
extension RepositoriesViewController: NSMenuDelegate {

    /// Once a menu gets requested by a `right click` setup the menu
    ///
    /// If the right click happened outside a row this will result in no menu being shown.
    /// - Parameter menu: The menu that got requested
    func menuNeedsUpdate(_ menu: NSMenu) {
        let row = outlineView.clickedRow
        guard let menu = menu as? RepositoriesMenu else { return }

        if row == -1 {
            menu.repository = nil
        } else {
            // TODO: Distinguish between repo, container, branch, etc.
            menu.repository = self.repository
            menu.workspace = workspace
        }
        menu.update()
    }
}
