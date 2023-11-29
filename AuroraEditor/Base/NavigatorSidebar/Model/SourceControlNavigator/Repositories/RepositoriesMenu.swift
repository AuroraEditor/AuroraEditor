//
//  RepositoriesMenu.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 17/8/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers
import Version_Control

/// A subclass of `NSMenu` implementing the contextual menu for the project navigator
final class RepositoriesMenu: NSMenu {

    /// The workspace, for opening the item
    var workspace: WorkspaceDocument?

    var repository: RepositoryModel?

    var outlineView: NSOutlineView

    var item: RepoItem?

    init(sender: NSOutlineView, workspaceURL: URL) {
        outlineView = sender
        super.init(title: "Options")
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Creates a `NSMenuItem` depending on the given arguments
    /// - Parameters:
    ///   - title: The title of the menu item
    ///   - action: A `Selector` or `nil` of the action to perform.
    ///   - key: A `keyEquivalent` of the menu item. Defaults to an empty `String`
    /// - Returns: A `NSMenuItem` which has the target `self`
    private func menuItem(_ title: String, action: Selector?, key: String = "") -> NSMenuItem {
        let mItem = NSMenuItem(title: title, action: action, keyEquivalent: key)
        mItem.target = self

        return mItem
    }

    /// Setup the menu and disables certain items when `isFile` is false
    /// - Parameter isFile: A flag indicating that the item is a file instead of a directory
    private func setupMenu() {
        guard let branch = item as? RepoBranch else { return }

        items = [
            menuItem("New Branch from \"\(branch.name)\"", action: #selector(createNewBranch)),
            menuItem("Rename \"\(branch.name)\"", action: #selector(renameBranch)),
            menuItem("Tag \"\(branch.name)\"", action: #selector(createNewTag)),
            menuItem("Switch...", action: isSelectedBranchCurrentOne() ? nil : #selector(switchToBranch(_:))),
            NSMenuItem.separator(),
            menuItem("Merge from Branch...", action: nil),
            menuItem("Merge into Branch...", action: nil),
            NSMenuItem.separator(),
            menuItem("New \"\(repository?.repoName ?? "Unknown Repository")\" Remote...",
                     action: nil),
            menuItem("Add Existing Remote...", action: #selector(addNewRemote)),
            NSMenuItem.separator(),
            menuItem("View on [Remote Provider]", action: nil),
            menuItem("Apply Stashed Changes...", action: nil),
            menuItem("Export Stashed Changes as Patch File...", action: nil),
            NSMenuItem.separator(),
            menuItem("Delete", action: isSelectedBranchCurrentOne() ? nil : #selector(deleteBranch))
        ]
    }

    @objc
    private func createNewBranch() {
        guard let branch = item as? RepoBranch else { return }

        workspace?.data.showBranchCreationSheet.toggle()
        workspace?.data.branchRevision = branch.name
    }

    @objc
    private func createNewTag() {
        guard let branch = item as? RepoBranch else { return }

        // Get a list of commits for the selected branch. We only get the latest 2 commits of
        // the branch so that we know what commit is newer.
        do {
            let commits = try GitLog().getCommits(directoryURL: (workspace!.workspaceURL()),
                                                  revisionRange: branch.name,
                                                  limit: 2,
                                                  skip: 0)

            // Get the first commit in the list and then get its commit hash
            let commitHash = commits[0]

            workspace?.data.commitHash = commitHash.sha
        } catch {
            Log.error("Unable to fetch commits for branch: \(branch.name)")
        }

        workspace?.data.showTagCreationSheet.toggle()
    }

    @objc
    func addNewRemote() {
        workspace?.data.showAddRemoteView.toggle()
    }

    @objc func switchToBranch(_ sender: Any?) {
        guard let branch = item as? RepoBranch else { return }
        try? workspace?.fileSystemClient?.model?.gitClient.checkoutBranch(name: branch.name)
        self.outlineView.reloadData()
    }

    @objc
    private func renameBranch() {
        guard let branch = item as? RepoBranch else { return }

        workspace?.data.currentlySelectedBranch = branch.name
        workspace?.data.showRenameBranchSheet.toggle()
    }

    @objc
    func deleteBranch() {
        guard let branch = item as? RepoBranch else { return }

        let alert = NSAlert()
        alert.messageText = "Do you want to delete the branch “\(branch.name)”?"
        alert.informativeText = "The branch will be removed from the repository. You can’t undo this action."
        alert.addButton(withTitle: "Delete")
        alert.addButton(withTitle: "Cancel")
        if alert.runModal() == .alertFirstButtonReturn {
            do {
                if try Branch().deleteLocalBranch(directoryURL: (workspace?.workspaceURL())!,
                                                  branchName: branch.name) {
                    self.outlineView.reloadData()
                } else {
                    Log.error("Failed to delete branch \(branch.name)")
                }
            } catch {
                Log.error("Failed to delete branch \(branch.name)")
            }
        }
    }

    /// Updates the menu for the selected item and hides it if no item is provided.
    override func update() {
        removeAllItems()
        setupMenu()
    }

    func isSelectedBranchCurrentOne() -> Bool {
        guard let branch = item as? RepoBranch else { return false }
        do {
            let currentBranch = try Branch().getCurrentBranch(directoryURL: (workspace?.workspaceURL())!)

            return currentBranch == branch.name
        } catch {
            Log.error("Failed to find current branch name.")
            return false
        }
    }
}
