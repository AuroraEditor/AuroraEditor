//
//  SourceControlController.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/10.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

final class SourceControlController: NSViewController {

    typealias Item = FileItem

    private var scrollView: NSScrollView!
    private var outlineView: NSOutlineView!

    var workspace: WorkspaceDocument?

    var iconColor: AppPreferences.FileIconStyle = .color
    var fileExtensionVisibility: AppPreferences.FileExtensionsVisibility = .showAll
    var shownFileExtensions: AppPreferences.FileExtensions = .default
    var hiddenFileExtensions: AppPreferences.FileExtensions = .default

    var rowHeight: Double = 22 {
        didSet {
            outlineView.rowHeight = rowHeight
            outlineView.reloadData()
        }
    }

    private var shouldSendSelectionUpdate: Bool = true

    override func loadView() {
        self.scrollView = NSScrollView()
        self.view = scrollView

        outlineView = NSOutlineView()
        outlineView.dataSource = self
        outlineView.delegate = self
        outlineView.autosaveExpandedItems = true
        outlineView.headerView = nil
        outlineView.menu = SourceControlMenu(sender: outlineView, workspaceURL: (workspace?.fileURL)!)
        outlineView.menu?.delegate = self

        let column = NSTableColumn(identifier: .init(rawValue: "SourceControlCell"))
        column.title = "Source Control"
        outlineView.addTableColumn(column)

        scrollView.documentView = outlineView
        scrollView.contentView.automaticallyAdjustsContentInsets = false
        scrollView.contentView.contentInsets = .init(top: 10, left: 0, bottom: 0, right: 0)
        scrollView.scrollerStyle = .overlay
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
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
}

extension SourceControlController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        return workspace?.fileSystemClient?.model?.changed.count ?? 0
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        return workspace?.fileSystemClient?.model?.changed[index] ?? 0
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let item = item as? Item {
            return item.children != nil
        }
        return false
    }
}

extension SourceControlController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView,
                     shouldShowCellExpansionFor tableColumn: NSTableColumn?,
                     item: Any) -> Bool {
        true
    }

    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        true
    }

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {

        guard let tableColumn = tableColumn else { return nil }

        let frameRect = NSRect(x: 0, y: 0, width: tableColumn.width, height: rowHeight)

        return SourceControlTableViewCell(frame: frameRect, item: item as? Item)
    }

    private func outlineViewLabel(for item: Item) -> String {
        switch fileExtensionVisibility {
        case .hideAll:
            return item.fileName(typeHidden: true)
        case .showAll:
            return item.fileName(typeHidden: false)
        case .showOnly:
            return item.fileName(typeHidden: !shownFileExtensions.extensions.contains(item.fileType.rawValue))
        case .hideOnly:
            return item.fileName(typeHidden: hiddenFileExtensions.extensions.contains(item.fileType.rawValue))
        }
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let outlineView = notification.object as? NSOutlineView else {
            return
        }

        let selectedIndex = outlineView.selectedRow

        guard let navigatorItem = outlineView.item(atRow: selectedIndex) as? Item else { return }

        if !navigatorItem.isFolder && shouldSendSelectionUpdate && navigatorItem.doesExist {
            workspace?.openTab(item: navigatorItem)
            Log.warning("Opened a new tab for: \(navigatorItem.url)")
        }
    }

    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        rowHeight // This can be changed to 20 to match Xcode's row height.
    }
}

extension SourceControlController: NSMenuDelegate {

    /// Once a menu gets requested by a `right click` setup the menu
    ///
    /// If the right click happened outside a row this will result in no menu being shown.
    /// - Parameter menu: The menu that got requested
    func menuNeedsUpdate(_ menu: NSMenu) {
        let row = outlineView.clickedRow
        guard let menu = menu as? SourceControlMenu else { return }

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
