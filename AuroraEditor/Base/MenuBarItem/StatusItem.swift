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
        let recentProjectPaths = ( UserDefaults.standard.array(forKey: "recentProjectPaths") as? [String] ?? [] )
            .filter { FileManager.default.fileExists(atPath: $0) }

        menuItem.submenu?.items = recentProjectPaths.map({ name in
            return RecentProjectMenuItem(title: name, action: #selector(openFile), keyEquivalent: "")
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.updateRecentProjects(in: menuItem)
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
        // add to recent projects
        var recentProjectPaths = (
            UserDefaults.standard.array(forKey: "recentProjectPaths") as? [String] ?? []
        ).filter { FileManager.default.fileExists(atPath: $0) }
        if let urlLocation = recentProjectPaths.firstIndex(of: repoPath) {
            recentProjectPaths.remove(at: urlLocation)
        }
        recentProjectPaths.insert(repoPath, at: 0)

        UserDefaults.standard.set(
            recentProjectPaths,
            forKey: "recentProjectPaths"
        )
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
        if AppDelegate.tryFocusWindow(of: AboutView.self) { return }
        AboutView().showWindow(width: 530, height: 220)
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
