//
//  SourceControlRelatedMenu.swift
//  Aurora Editor
//
//  Created by Miguel Themann on 24.09.23.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Version_Control

/// A menu that shows options related to source control for a file.
final class SourceControlRelatedMenu: NSMenu {
    typealias Item = FileItem

    /// The git client for the workspace.
    private let gitClient: GitClient

    /// The item that the menu is for.
    var item: Item?

    /// The workspace document.
    var workspace: WorkspaceDocument?

    /// The file manager.
    private let fileManager = FileManager.default

    /// The outline view that the menu is for.
    private var outlineView: NSOutlineView

    /// Initialize the menu.
    /// 
    /// - Parameter sender: the outline view
    /// - Parameter workspaceURL: the workspace URL
    /// 
    /// - Returns: the menu
    init(sender: NSOutlineView, workspaceURL: URL) {
        outlineView = sender
        gitClient = GitClient(directoryURL: workspaceURL, shellClient: sharedShellClient.shellClient)
        super.init(title: "Source Control Related Options")
    }

    /// Initialize the menu.
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Set the menu for a menu item.
    /// 
    /// - Parameter submenu: the menu
    /// - Parameter item: the item
    /// 
    /// - Returns: the menu item
    private func menuItem(_ title: String, action: Selector?, key: String = "") -> NSMenuItem {
        let mItem = NSMenuItem(title: title, action: action, keyEquivalent: key)
        mItem.target = self

        return mItem
    }

    /// Setup the menu.
    func setupMenu() {
        let commitFile = menuItem("Commit \"\(item?.fileName ?? "Selected Files")\"...", action: nil)

        let discardChanges = menuItem("Discard Changes in \"\(item?.fileName ?? "Selected Files")\"...",
                                      action: #selector(discardChangesInFile))

        let addSelectedFiles = menuItem("Add Selected Files...", action: #selector(addSelectedFiles))
        let unstageSelectedFiles = menuItem("Unstage Selected Files...", action: #selector(unstageSelectedFiles))
        let markAsResolved = menuItem("Mark Selected Files as Resolved", action: nil)

        items = [
            commitFile,
            discardChanges,
            NSMenuItem.separator(),
            addSelectedFiles,
            unstageSelectedFiles,
            markAsResolved
        ]
    }

    // TODO: Need to find a way to check for changes in the current selected file
    /// Commit the changes in the file.
    @objc
    private func discardChangesInFile() {
        let alert = NSAlert()
        alert.messageText = "Do you want to permanently discard all changes to \"\(item?.fileName ?? "")\"?"
        alert.informativeText = "You can't undo this action"
        alert.alertStyle = .critical
        alert.addButton(withTitle: "Discard Changes")
        alert.buttons.last?.hasDestructiveAction = true
        alert.addButton(withTitle: "Cancel")
        if alert.runModal() == .alertFirstButtonReturn {
            do {
                try gitClient.discardFileChanges(url: (item?.url.path)!)
            } catch {
                Log.fault("Error when trying to discard changes in file!")
            }
        }
    }

    /// Add the selected files to the staging area.
    @objc
    private func addSelectedFiles() {
        guard let fileName = item?.fileName else { return }
        try? gitClient.stage(files: [fileName])
    }

    /// Unstage the selected files.
    @objc private func unstageSelectedFiles() {
        guard let fileName = item?.fileName else { return }
        try? gitClient.unstage(files: [fileName])
    }
}
