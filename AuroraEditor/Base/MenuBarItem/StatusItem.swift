//
//  StatusItem.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 4/9/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

extension AppDelegate {
    private var appVersion: String {
        return Bundle.versionString ?? "No Version"
    }

    private var appBuild: String {
        return Bundle.buildString ?? "No Build"
    }

    func setup(statusItem: NSStatusItem) {
        if let button = statusItem.button {
            button.image = NSImage(named: "MenuBarIcon")
        }

        let menu = NSMenu()

        let recentProjectsItem = NSMenuItem(title: "Recent Projects", action: nil, keyEquivalent: "")
        recentProjectsItem.submenu = NSMenu()
        updateRecentProjects(in: recentProjectsItem)

        menu.items = [
            NSMenuItem(title: "Create a new file", action: #selector(newFile), keyEquivalent: "1"),
            NSMenuItem(title: "Clone an existing project", action: #selector(cloneProject), keyEquivalent: "2"),
            NSMenuItem(title: "Open a project or file", action: #selector(openProject), keyEquivalent: "3"),
            recentProjectsItem,
            NSMenuItem.separator(),
            NSMenuItem(title: "Version \(appVersion) (\(appBuild))",
                       action: #selector(copyInformation), keyEquivalent: ""),
            NSMenuItem(title: "About AuroraEditor", action: #selector(about), keyEquivalent: ""),
            NSMenuItem(title: "Preferences", action: #selector(openPreferences), keyEquivalent: ","),
            NSMenuItem.separator(),
            NSMenuItem(title: "Open Welcome View", action: #selector(openWelcome), keyEquivalent: "e"),
            NSMenuItem(title: "Hide this item", action: #selector(hideMenuItem), keyEquivalent: "h"),
            NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        ]
        statusItem.menu = menu
    }

    func updateRecentProjects(in menuItem: NSMenuItem) {
        DispatchQueue.main.async {
            RecentProjectsStore.shared.$paths
                .map { paths in
                    paths.map {
                        RecentProjectMenuItem(
                            title: $0,
                            action: #selector(self.openFile),
                            keyEquivalent: ""
                        )
                    }
                }
                .sink { items in
                    menuItem.submenu?.items = items
                    menuItem.isEnabled = !items.isEmpty
                }
                .store(in: &self.cancellable)
        }
    }

    @objc
    func openFile(_ sender: Any?) {
        guard let sender = sender as? RecentProjectMenuItem else { return }
        let repoPath = sender.urlString
        // open the document
        let repoFileURL = URL(fileURLWithPath: repoPath)
        Log.info("Opening \(repoFileURL)")
        AuroraEditorDocumentController.shared.openDocument(
            withContentsOf: repoFileURL,
            display: true,
            completionHandler: { _, _, _ in }
        )
        DispatchQueue.main.async {
            RecentProjectsStore.shared.record(path: repoPath)
        }
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
    func copyInformation(_ sender: Any?) {
        AuroraEditor.copyInformation()
    }

    @objc
    func about(_ sender: Any?) {
        AppDelegate.openAboutWindow()
    }

    @objc
    func hideMenuItem(_ sender: Any?) {
        statusItem.button?.isHidden = true
        AppPreferencesModel.shared.preferences.general.menuItemShowMode = .hidden
    }
}

class RecentProjectMenuItem: NSMenuItem {
    var urlString: String = ""

    override init(title: String, action selector: Selector?, keyEquivalent charCode: String) {
        urlString = title
        super.init(title: urlString.abbreviatingWithTildeInPath(), action: selector, keyEquivalent: charCode)
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}
