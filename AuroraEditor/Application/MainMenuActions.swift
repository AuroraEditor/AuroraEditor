//
//  MainMenuActions.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/06.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import AppKit

final class MainMenuActions: NSWindowController {

    var workspace: WorkspaceDocument?

    // MARK: Git Main Menu Items

    @IBAction func stashChangesItems(_ sender: Any) {
        if (workspace?.workspaceClient?.model?.changed ?? []).isEmpty {
            let alert = NSAlert()
            alert.alertStyle = .informational
            alert.messageText = "Cannot Stash Changes"
            alert.informativeText = "There are no uncommitted changes in the working copies for this project."
            alert.addButton(withTitle: "OK")
            alert.runModal()
        } else {
            workspace?.showStashChangesSheet.toggle()
        }
    }

    @IBAction func discardProjectChanges(_ sender: Any) {
        if (workspace?.workspaceClient?.model?.changed ?? []).isEmpty {
            let alert = NSAlert()
            alert.alertStyle = .informational
            alert.messageText = "Cannot Discard Changes"
            alert.informativeText = "There are no uncommitted changes in the working copies for this project."
            alert.addButton(withTitle: "OK")
            alert.runModal()
        } else {
            workspace?.workspaceClient?.model?.discardProjectChanges()
        }
    }
}
