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
        outlineView.menu = TabHierarchyMenu(sender: self.outlineView)
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
        let selectedIndex = outlineView.selectedRow
        guard let item = outlineView.item(atRow: selectedIndex) as? TabBarItemStorage,
              let itemTab = workspace?.selectionState.getItemByTab(id: item.tabBarID) else { return }
        DispatchQueue.main.async {
            self.workspace?.openTab(item: itemTab)
        }
    }
}
