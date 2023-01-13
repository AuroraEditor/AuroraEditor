//
//  EditableListViewController.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2023/01/13.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Combine

/// Adds a ``outlineView`` inside a ``scrollView``
final class EditableListViewController: NSViewController {

    typealias Item = FileSystemClient.FileItem
    let dragType: NSPasteboard.PasteboardType = .fileURL

    @ObservedObject
    var prefs: AppPreferencesModel = .shared

    var scrollView: NSScrollView!
    var outlineView: NSOutlineView!

    var cancelables: Set<AnyCancellable> = .init()

    var content: [String] {
        return prefs.preferences.general.hiddenFilesAndFolders
    }

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
    var shouldSendSelectionUpdate: Bool = true

    /// Setup the ``scrollView`` and ``outlineView``
    override func loadView() {
        self.scrollView = NSScrollView()
        self.view = scrollView

        self.outlineView = NSOutlineView()
        outlineView.dataSource = self
        outlineView.delegate = self
        outlineView.autosaveExpandedItems = true
        outlineView.autosaveName =  "Hidden Folders and Files"
        outlineView.headerView = nil
        outlineView.doubleAction = #selector(onItemDoubleClicked)

        let column = NSTableColumn(identifier: .init(rawValue: "Cell"))
        column.title = "Cell"
        outlineView.addTableColumn(column)

        scrollView.documentView = outlineView
        scrollView.contentView.automaticallyAdjustsContentInsets = false
        scrollView.scrollerStyle = .overlay
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
    }

    override func viewDidDisappear() {
        cancelables.forEach({ $0.cancel() })
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    @objc
    private func onItemDoubleClicked() {
        guard let item = outlineView.item(atRow: outlineView.clickedRow) as? String else { return }

        Log.debug("Selected Item: \(item)")
    }
}
