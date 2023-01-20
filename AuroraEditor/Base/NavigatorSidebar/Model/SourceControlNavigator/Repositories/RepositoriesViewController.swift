//
//  RepositoriesViewController.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 17/8/22.
//

import SwiftUI

/// A `NSViewController` that handles the **Repositories View** in the **Source Control Navigator**.
///
/// Adds a ``outlineView`` inside a ``scrollView`` which shows the folder structure of the
/// currently open project.
final class RepositoriesViewController: NSViewController {

    var repository: RepositoryModel!

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
    func updateSelection() { // TODO: Selection
//        guard let itemID = workspace?.selectionState.selectedId else {
//            outlineView.deselectRow(outlineView.selectedRow)
//            return
//        }
//
//        select(by: itemID, from: content)
    }

    /// Expand or collapse the folder on double click
    @objc
    private func onItemDoubleClicked() {
        // TODO: Double click stuff
        let item = outlineView.item(atRow: outlineView.clickedRow)

        if item is RepositoryModel || item is RepoContainer {
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
        if item is RepositoryModel {
            // item is a repo
            return 5
        } else if let item = item as? RepoContainer {
            // item is a container
            return item.contents.count
        } else if item is RepoItem {
            // item is an item, and therefore has no children
            return 0
        }
        // it might be the top level item, return 1 for the repo
        return 1
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let item = item as? RepositoryModel {
            // item is a repo.
            switch index {
            case 0:
                return item.branches ?? []
            case 1:
                return item.recentLocations ?? []
            case 2:
                return item.tags ?? []
            case 3:
                return item.stashedChanges ?? []
            case 4:
                return item.remotes ?? []
            default:
                return 0
            }
        } else if let item = item as? RepoContainer {
            // item is a container
            return item.contents[index]
        } else if item is RepoItem {
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
        return item is RepositoryModel || item is RepoContainer
    }
}

// MARK: - NSOutlineViewDelegate

extension RepositoriesViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView,
                     shouldShowCellExpansionFor tableColumn: NSTableColumn?,
                     item: Any) -> Bool {
        true
    }

    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        true
    }

    // swiftlint:disable:next cyclomatic_complexity
    func outlineView(_ outlineView: NSOutlineView,
                     viewFor tableColumn: NSTableColumn?,
                     item: Any) -> NSView? {
        guard let tableColumn = tableColumn else { return nil }

        let frameRect = NSRect(x: 0, y: 0, width: tableColumn.width, height: rowHeight)

        if let item = item as? RepositoryModel {
            // item is a repo.
            return RepositoriesTableViewCell(frame: frameRect,
                                             repository: item,
                                             represents: .repo)
        } else if let item = item as? RepoContainer {
            var represents: RepositoriesTableViewCell.CellType?
            // item is a container
            if item is RepoBranches {
                represents = .branches
            } else if item is RepoRecentLocations {
                represents = .recentLocations
            } else if item is RepoStashedChanges {
                represents = .stashedChanges
            } else if item is RepoTags {
                represents = .tags
            } else if item is RepoRemotes {
                represents = .remotes
            } else if item is RepoRemote {
                represents = .remote
            }
            if let represents = represents {
                return RepositoriesTableViewCell(frame: frameRect,
                                                 repository: repository,
                                                 represents: represents)
            }
        } else if let item = item as? RepoItem {
            var represents: RepositoriesTableViewCell.CellType?
            if item is RepoBranch {
                represents = .branch
            } else if item is RepoTag {
                represents = .tag
            } else if item is RepoChange {
                represents = .change
            }
            if let represents = represents {
                return RepositoriesTableViewCell(frame: frameRect,
                                                 repository: repository,
                                                 represents: represents,
                                                 item: item)
            }
        }
        return nil
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
        let selectedIndex = outlineView.selectedRow
        if outlineView.item(atRow: selectedIndex) is RepoContainer {
            workspace?.openTab(item: ProjectCommitHistory(workspace: workspace!))
        } else if let selectedBranch = outlineView.item(atRow: selectedIndex) as? RepoBranch {
            workspace?.openTab(item: BranchCommitHistory(workspace: workspace!,
                                                         branchName: selectedBranch.name))
        }
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
            menu.item = outlineView.item(atRow: row) as? RepoItem
        }
        menu.update()
    }
}
