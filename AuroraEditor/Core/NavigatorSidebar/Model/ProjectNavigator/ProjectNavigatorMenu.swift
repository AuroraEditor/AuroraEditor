//
//  ProjectNavigatorMenu.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 14/8/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

/// A subclass of `NSMenu` implementing the contextual menu for the project navigator
@MainActor
final class ProjectNavigatorMenu: NSMenu {
    typealias Item = FileSystemClient.FileItem

    /// The git client
    let gitClient: GitClient?

    /// The item to show the contextual menu for
    var item: Item?

    /// The workspace, for opening the item
    var workspace: WorkspaceDocument?

    /// The file manager
    private let fileManger = FileManager.default

    /// The outline view
    var outlineView: NSOutlineView

    /// Initializes the menu with the given outline view and workspace URL
    /// 
    /// - Parameter sender: the outline view
    /// - Parameter workspaceURL: the workspace URL
    /// 
    /// - Returns: the menu
    init(sender: NSOutlineView, workspaceURL: URL) {
        outlineView = sender
        gitClient = workspace?.fileSystemClient?.model?.gitClient
        super.init(title: "Options")
    }

    /// Initializes the menu with the given outline view
    /// 
    /// - Parameter coder: coder
    /// 
    /// - Returns: the menu
    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Creates a `NSMenuItem` depending on the given arguments
    /// 
    /// - Parameters:
    ///   - title: The title of the menu item
    ///   - action: A `Selector` or `nil` of the action to perform.
    ///   - key: A `keyEquivalent` of the menu item. Defaults to an empty `String`
    /// 
    /// - Returns: A `NSMenuItem` which has the target `self`
    private func menuItem(_ title: String, action: Selector?, key: String = "") -> NSMenuItem {
        let mItem = NSMenuItem(title: title, action: action, keyEquivalent: key)
        mItem.target = self

        return mItem
    }

    /// Setup the menu and disables certain items when `isFile` is false
    /// 
    /// - Parameter isFile: A flag indicating that the item is a file instead of a directory
    private func setupMenu() {
        guard let item = item else { return }

        let openAs = menuItem("Open As", action: nil)

        let sortByName = menuItem("Sort by Name", action: nil)
        sortByName.isEnabled = item.isFolder

        let sortByType = menuItem("Sort by Type", action: nil)
        sortByType.isEnabled = item.isFolder

        let sourceControl = menuItem("Source Control", action: nil)

        let openInTerminal = menuItem("Open in Integrated Terminal", action: #selector(openInIntegratedTerminal))
        openInTerminal.isHidden = !item.isFolder

        items = [
            menuItem("Show in Finder", action: #selector(showInFinder)),
            NSMenuItem.separator(),
            menuItem("Open in Tab", action: #selector(openInTab)),
            menuItem("Open in New Window", action: nil),
            menuItem("Open with External Editor", action: #selector(openWithExternalEditor)),
            openInTerminal,
            openAs,
            NSMenuItem.separator(),
            menuItem("Show File Inspector", action: nil),
            NSMenuItem.separator(),
            menuItem("New File...", action: #selector(newFile)),
            menuItem("New File From Template...", action: #selector(newFileFromTemplate)),
            menuItem("New Folder", action: #selector(newFolder)),
            NSMenuItem.separator(),
            menuItem("Rename", action: #selector(renameFile)),
            menuItem("Delete", action: item.url != workspace?.fileSystemClient?.folderURL
                     ? #selector(delete) : nil),
            menuItem("Duplicate \(item.isFolder ? "Folder" : "File")", action: #selector(duplicate)),
            NSMenuItem.separator(),
            sortByName,
            sortByType,
            NSMenuItem.separator(),
            sourceControl
        ]

        setSubmenu(openAsMenu(item: item), for: openAs)
        setSubmenu(sourceControlMenu(item: item), for: sourceControl)
    }

    /// Submenu for **Open As** menu item.
    /// 
    /// - Parameter item: The item to open
    /// 
    /// - Returns: The submenu
    private func openAsMenu(item: Item) -> NSMenu {
        let openAsMenu = NSMenu(title: "Open As")
        func getMenusItems() -> ([NSMenuItem], [NSMenuItem]) {
            // Use UTType to distinguish between bundle file and user-browsable directory
            // The isDirectory property is not accurate on this.
            guard let type = item.contentType else { return ([.none()], []) }
            if type.conforms(to: .folder) {
                return ([.none()], [])
            }
            var primaryItems = [NSMenuItem]()
            if type.conforms(to: .sourceCode) {
                primaryItems.append(.sourceCode())
            }
            if type.conforms(to: .propertyList) {
                primaryItems.append(.propertyList())
            }
            if let utType = UTType(filenameExtension: "xcassets"),
               type.conforms(to: utType) {
                primaryItems.append(NSMenuItem(title: "Asset Catalog Document", action: nil, keyEquivalent: ""))
            }
            if let utType = UTType(filenameExtension: "xib"),
               type.conforms(to: utType) {
                primaryItems.append(NSMenuItem(title: "Interface Builder XIB Document", action: nil, keyEquivalent: ""))
            }
            if let utType = UTType(filenameExtension: "xcodeproj"),
                type.conforms(to: utType) {
                primaryItems.append(NSMenuItem(title: "Xcode Project", action: nil, keyEquivalent: ""))
            }
            var secondaryItems = [NSMenuItem]()
            if type.conforms(to: .text) {
                secondaryItems.append(.asciiPropertyList())
                secondaryItems.append(.hex())
            }

            // FIXME: Update the quickLook condition
            if type.conforms(to: .data) {
                secondaryItems.append(.quickLook())
            }

            return (primaryItems, secondaryItems)
        }
        let (primaryItems, secondaryItems) = getMenusItems()
        for item in primaryItems {
            openAsMenu.addItem(item)
        }
        if !secondaryItems.isEmpty {
            openAsMenu.addItem(.separator())
        }
        for item in secondaryItems {
            openAsMenu.addItem(item)
        }
        return openAsMenu
    }

    /// Submenu for **Source Control** menu item.
    /// 
    /// - Parameter item: The item to open
    /// 
    /// - Returns: The submenu
    private func sourceControlMenu(item: Item) -> NSMenu {
        guard let workspaceURL = workspace?.workspaceURL() else {
            // TODO: Investigate more robust solutions
            fatalError("No workspace URL configured")
        }
        let menu = SourceControlRelatedMenu(sender: outlineView, workspaceURL: workspaceURL)
        menu.item = item
        menu.setupMenu()
        return menu
    }

    /// Updates the menu for the selected item and hides it if no item is provided.
    override func update() {
        removeAllItems()
        setupMenu()
    }

    /// Action that opens **Finder** at the items location.
    @objc
    private func showInFinder() {
        item?.showInFinder()
    }

    /// Action that opens the item, identical to clicking it.
    @objc
    private func openInTab() {
        if let item = item {
            workspace?.openTab(item: item)
        }
    }

    /// Action that opens in an external editor
    @objc
    private func openWithExternalEditor() {
        item?.openWithExternalEditor()
    }

    /// Action that navigates to the integrated terminal
    @objc
    private func openInIntegratedTerminal() {
        if let item = item, item.isFolder {
            NotificationCenter.default.post(
                name: .openInTerminal,
                object: item.url
            )
        }
    }

    /// Action that creates a new untitled file
    @objc
    private func newFile() {
        outlineView.expandItem((item?.isFolder ?? true) ? item : item?.parent)
        item?.addFile(fileName: "untitled")
    }

    /// Action that activates the FileCreationSelectionView
    @objc
    private func newFileFromTemplate() {
        if let nearestFolder = item?.nearestFolder {
            workspace?.newFileModel.showSheetWithUrl(url: nearestFolder)
        }
    }

    /// Action that creates a new untitled folder
    @objc
    private func newFolder() {
        outlineView.expandItem((item?.isFolder ?? true) ? item : item?.parent)
        item?.addFolder(folderName: "untitled")
    }

    /// Opens the rename file dialogue on the cell this was presented from.
    @objc
    private func renameFile() {
        let row = outlineView.row(forItem: item)
        guard row > 0,
            let cell = outlineView.view(atColumn: 0, row: row, makeIfNecessary: false)
                as? ProjectNavigatorTableViewCell else {
            return
        }
        outlineView.window?.makeFirstResponder(cell.textField)
    }

    /// Action that deletes the item.
    @objc
    private func delete() {
        guard let item = item else {
            return
        }

        let deleteConfirmation = NSAlert()
        let message = "\(item.fileName)\(item.isFolder ? " and its children" : "")"
        deleteConfirmation.messageText = "Do you want to move \(message) to the bin?"
        deleteConfirmation.alertStyle = .critical
        deleteConfirmation.addButton(withTitle: "Delete")
        deleteConfirmation.buttons.last?.hasDestructiveAction = true
        deleteConfirmation.addButton(withTitle: "Cancel")
        if deleteConfirmation.runModal() == .alertFirstButtonReturn { // "Delete" button
            if fileManger.fileExists(atPath: item.url.path) {
                do {
                    if workspace?.selectionState.openedTabs.contains(item.tabID) ?? false {
                        workspace?.closeTab(item: item.tabID)
                    }
                    // TODO: When file gets deleted we should update the Project Navigator
                    try FileItem.fileManger.trashItem(
                        at: item.url,
                        resultingItemURL: nil
                    )
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }

    /// Action that duplicates the item
    @objc
    private func duplicate() {
        item?.duplicate()
    }
}

extension NSMenuItem {
    /// Menu item for None
    /// 
    /// - Returns: The menu item
    fileprivate static func none() -> NSMenuItem {
        let item = NSMenuItem(title: "<None>", action: nil, keyEquivalent: "")
        item.isEnabled = false
        return item
    }

    /// Menu item for Source Code
    /// 
    /// - Returns: The menu item
    fileprivate static func sourceCode() -> NSMenuItem {
        NSMenuItem(title: "Source Code", action: nil, keyEquivalent: "")
    }

    /// Menu item for Property List
    /// 
    /// - Returns: The menu item
    fileprivate static func propertyList() -> NSMenuItem {
        NSMenuItem(title: "Property List", action: nil, keyEquivalent: "")
    }

    /// Menu item for ASCII Property List
    /// 
    /// - Returns: The menu item
    fileprivate static func asciiPropertyList() -> NSMenuItem {
        NSMenuItem(title: "ASCII Property List", action: nil, keyEquivalent: "")
    }

    /// Menu item for Hex
    /// 
    /// - Returns: The menu item
    fileprivate static func hex() -> NSMenuItem {
        NSMenuItem(title: "Hex", action: nil, keyEquivalent: "")
    }

    /// Menu item for Quick Look
    /// 
    /// - Returns: The menu item
    fileprivate static func quickLook() -> NSMenuItem {
        NSMenuItem(title: "Quick Look", action: nil, keyEquivalent: "")
    }
}
