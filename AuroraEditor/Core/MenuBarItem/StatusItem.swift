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
    /// Application version
    private var appVersion: String {
        return Bundle.versionString ?? "No Version"
    }

    /// Application build
    private var appBuild: String {
        return Bundle.buildString ?? "No Build"
    }

    /// Setup the status item
    /// 
    /// - Parameter statusItem: status item
    @MainActor
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

    /// Update the recent projects
    /// 
    /// - Parameter menuItem: menu item
    @MainActor
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

    /// Open file
    /// 
    /// - Parameter sender: sender
    @objc
    @MainActor
    func openFile(_ sender: Any?) {
        guard let sender = sender as? RecentProjectMenuItem else { return }
        let repoPath = sender.urlString
        // open the document
        let repoFileURL = URL(fileURLWithPath: repoPath)
        self.logger.info("Opening \(repoFileURL)")
        AuroraEditorDocumentController.shared.openDocument(
            withContentsOf: repoFileURL,
            display: true,
            completionHandler: { _, _, _ in }
        )
        DispatchQueue.main.async {
            RecentProjectsStore.shared.record(path: repoPath)
        }
    }

    /// New file
    /// 
    /// - Parameter sender: sender
    @objc
    @MainActor
    func newFile(_ sender: Any?) {
        AuroraEditorDocumentController.shared.newDocument(nil)
    }

    /// Clone project
    /// 
    /// - Parameter sender: sender
    @objc
    @MainActor
    func cloneProject(_ sender: Any?) {
        GitCloneView.openGitClientWindow()
    }

    /// Open project
    /// 
    /// - Parameter sender: sender
    @objc
    @MainActor
    func openProject(_ sender: Any?) {
        AuroraEditorDocumentController.shared.openDocument(
            onCompletion: { _, _ in },
            onCancel: {}
        )
    }

    /// Copy information
    /// 
    /// - Parameter sender: sender
    @objc
    func copyInformation(_ sender: Any?) {
        AuroraEditor.copyInformation()
    }

    /// Open about window
    /// 
    /// - Parameter sender: sender
    @objc
    @MainActor
    func about(_ sender: Any?) {
        AppDelegate.openAboutWindow()
    }

    /// Hide menu item
    /// 
    /// - Parameter sender: sender
    @objc
    @MainActor
    func hideMenuItem(_ sender: Any?) {
        statusItem?.button?.isHidden = true
        AppPreferencesModel.shared.preferences.general.menuItemShowMode = .hidden
    }
}

/// Recent project menu item
class RecentProjectMenuItem: NSMenuItem {
    /// URL string
    var urlString: String = ""

    /// Initialize the menu item
    /// 
    /// - Parameter title: title
    /// - Parameter selector: selector
    /// - Parameter charCode: char code
    /// 
    /// - Returns: menu item
    override init(title: String, action selector: Selector?, keyEquivalent charCode: String) {
        urlString = title
        super.init(title: urlString.abbreviatingWithTildeInPath(), action: selector, keyEquivalent: charCode)
    }

    /// Initialize the menu item
    /// 
    /// - Parameter coder: coder
    /// 
    /// - Returns: menu item
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}
