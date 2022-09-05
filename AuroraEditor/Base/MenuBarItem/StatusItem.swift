//
//  StatusItem.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 4/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

extension AppDelegate {

    func setup(statusItem: NSStatusItem) {
        if let button = statusItem.button {
            button.image = NSImage(named: "MenuBarIcon")
        }

        let menu = NSMenu()

        menu.items = [
            NSMenuItem(title: "Create a new file", action: #selector(newFile), keyEquivalent: "1"),
            NSMenuItem(title: "Clone an existing project", action: #selector(cloneProject), keyEquivalent: "2"),
            NSMenuItem(title: "Open a project or file", action: #selector(openProject), keyEquivalent: "3"),
            NSMenuItem.separator(),
            NSMenuItem(title: "Preferences", action: #selector(openPreferences), keyEquivalent: ","),
            NSMenuItem(title: "Open Welcome View", action: #selector(openWelcome), keyEquivalent: "e"),
            NSMenuItem.separator(),
            NSMenuItem(title: "Hide this item", action: #selector(hideMenuItem), keyEquivalent: "h"),
            NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        ]
        statusItem.menu = menu
    }

    @objc
    func newFile(_ sender: Any?) {
        AuroraEditorDocumentController.shared.newDocument(nil)
    }

    @objc
    func cloneProject(_ sender: Any?) {
        GitCloneView.openGitClientWindow()
    }

    @objc
    func openProject(_ sender: Any?) {
        AuroraEditorDocumentController.shared.openDocument(
            onCompletion: { _, _ in },
            onCancel: {}
        )
    }

    @objc
    func hideMenuItem(_ sender: Any?) {
        statusItem.button?.isHidden = true
        AppPreferencesModel.shared.preferences.general.menuItemShowMode = .hidden
    }
}
