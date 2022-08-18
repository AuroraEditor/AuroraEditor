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
        self.scrollView.contentView.contentInsets = .init(top: 10, left: 0, bottom: 0, right: 0)
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

        if item is DummyRepo || item is DummyRepo.DummyContainer {
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
        if let item = item as? DummyRepo {
            // item is a repo.
            // if it is a remote, it will only contain its branches
            guard item.isLocal else { return item.branches.count }
            // else, it will contain Branches, Recent Locations, Tags, Stashed Changes, and Remotes
            return item.containers.count
        } else if let item = item as? DummyRepo.DummyContainer {
            // item is a container
            switch item.type {
            case .branches:
                return repository.branches.count
            case .recentLocations:
                return repository.recentBranches.count
            case .stashedChanges:
                return repository.stashedChanges.count
            case .tags:
                return repository.tags.count
            case .remotes:
                return repository.remotes.count
            }
        } else if item is DummyRepo.DummyBranch {
            // item is a branch, has no children
            return 0
        }
        // else it might be the top level item, return 1 for the repo
        return 1
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let item = item as? DummyRepo {
            // item is a repo.
            // if it is a remote, it will only contain its branches
            guard item.isLocal else { return item.branches[index] }
            // else, it will contain Branches, Recent Locations, Tags, Stashed Changes, and Remotes
            return item.containers[index]
        } else if let item = item as? DummyRepo.DummyContainer {
            // item is a container
            switch item.type {
            case .branches:
                return repository.branches[index]
            case .recentLocations:
                return repository.recentBranches[index]
            case .stashedChanges:
                return repository.stashedChanges[index]
            case .tags:
                return repository.tags[index]
            case .remotes:
                return repository.remotes[index]
            }
        } else if item is DummyRepo.DummyBranch {
            // item is a branch, has no children
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
        return item is DummyRepo || item is DummyRepo.DummyContainer
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

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let tableColumn = tableColumn else { return nil }

        let frameRect = NSRect(x: 0, y: 0, width: tableColumn.width, height: rowHeight)

        if let item = item as? DummyRepo {
            // item is a repo.
            return RepositoriesTableViewCell(frame: frameRect,
                                             repository: item,
                                             represents: .repo)
        } else if let item = item as? DummyRepo.DummyContainer {
            // item is a container
            switch item.type {
            case .branches:
                return RepositoriesTableViewCell(frame: frameRect,
                                                 repository: repository,
                                                 represents: .branches)

            case .recentLocations:
                return RepositoriesTableViewCell(frame: frameRect,
                                                 repository: repository,
                                                 represents: .recentLocations)

            case .stashedChanges:
                return RepositoriesTableViewCell(frame: frameRect,
                                                repository: repository,
                                                represents: .stashedChanges)

            case .tags:
                return RepositoriesTableViewCell(frame: frameRect,
                                                 repository: repository,
                                                 represents: .tags)

            case .remotes:
                return RepositoriesTableViewCell(frame: frameRect,
                                                 repository: repository,
                                                 represents: .remotes)
            }
        } else if let item = item as? DummyRepo.DummyBranch {
            // item is a branch, has no children
            // TODO: Make this distinguish between local and remote.
            // Currently it assumes the branch's parent is the main repo. This usually isn't a problem
            // except when a branch exists in the main repo that doesn't in the remote
            // one possible implementation is to put a parent property into the branch, and from there
            // detect if the branch is owned by a remote or a local
            return RepositoriesTableViewCell(frame: frameRect,
                                             repository: repository,
                                             represents: .branch,
                                             branchNumber: repository.branches.firstIndex(where: {
                $0.name == item.name
            }))
        }
        return nil
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
        let selectedIndex = outlineView.selectedRow
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
