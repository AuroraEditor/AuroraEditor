//
//  SourceControlRelatedMenu.swift
//  Aurora Editor
//
//  Created by Miguel Themann on 24.09.23.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Version_Control

final class SourceControlRelatedMenu: NSMenu {
    typealias Item = FileItem
    
    private let gitClient: GitClient
    
    var item: Item?
    
    var workspace: WorkspaceDocument?
    
    private let fileManager = FileManager.default
    
    private var outlineView: NSOutlineView
    
    init(sender: NSOutlineView, workspaceURL: URL) {
        outlineView = sender
        gitClient = GitClient(directoryURL: workspaceURL, shellClient: sharedShellClient.shellClient)
        super.init(title: "Source Control Related Options")
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func menuItem(_ title: String, action: Selector?, key: String = "") -> NSMenuItem {
        let mItem = NSMenuItem(title: title, action: action, keyEquivalent: key)
        mItem.target = self

        return mItem
    }
    
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
                Log.error("Error when trying to discard changes in file!")
            }
        }
    }

    @objc
    private func addSelectedFiles() {
        guard let fileName = item?.fileName else { return }
        try? gitClient.stage(files: [fileName])
    }
    
    @objc private func unstageSelectedFiles() {
        guard let fileName = item?.fileName else { return }
        try? gitClient.unstage(files: [fileName])
    }
}
