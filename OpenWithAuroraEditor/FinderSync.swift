//
//  FinderSync.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 03/05/2022.
//

import Cocoa
import FinderSync

class AEOpenWith: FIFinderSync {
    override init() {
        super.init()
        // Add finder sync
        let finderSync = FIFinderSyncController.default()
        if let mountedVolumes = FileManager.default.mountedVolumeURLs(
            includingResourceValuesForKeys: nil,
            options: [.skipHiddenVolumes]) {
            finderSync.directoryURLs = Set<URL>(mountedVolumes)
        }
        // Monitor volumes
        let notificationCenter = NSWorkspace.shared.notificationCenter
        notificationCenter.addObserver(
            forName: NSWorkspace.didMountNotification,
            object: nil,
            queue: .main) { notification in
                if let volumeURL = notification.userInfo?[NSWorkspace.volumeURLUserInfoKey] as? URL {
                    finderSync.directoryURLs.insert(volumeURL)
                }
        }
    }

    /// Open in Aurora Editor (menu) action
    /// - Parameter sender: sender
    @objc func openInAuroraEditorAction(_ sender: AnyObject?) {
        guard let items = FIFinderSyncController.default().selectedItemURLs(),
              let defaults = UserDefaults(suiteName: "com.auroraeditor.shared") else {
            return
        }

        // Make values compatible to ArrayLiteralElement
        var files = ""

        for obj in items {
            files.append("\(obj.path);")
        }

        guard let urlForAuroraEditor = NSWorkspace.shared.urlForApplication(
            withBundleIdentifier: "com.auroraeditor"
        ) else { return }

        // Add files to open to openInAEFiles.
        defaults.set(files, forKey: "openInAEFiles")

        NSWorkspace.shared.open(
            [],
            withApplicationAt: urlForAuroraEditor,
            configuration: NSWorkspace.OpenConfiguration()
        )
    }

    // MARK: - Menu and toolbar item support
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        guard let defaults = UserDefaults(suiteName: "com.auroraeditor.shared") else {
            NSLog("Unable to load defaults")
            return NSMenu(title: "")
        }

        // Register enableOpenInAE (enable Open In Aurora Editor
        defaults.register(defaults: ["enableOpenInAE": true])

        let menu = NSMenu(title: "")
        let menuItem = NSMenuItem(title: "Open in Aurora Editor",
                                  action: #selector(openInAuroraEditorAction(_:)),
                                  keyEquivalent: ""
        )
        menuItem.image = NSImage(named: "icon")

        if defaults.bool(forKey: "enableOpenInAE") {
            menu.addItem(menuItem)
        }

        return menu
    }
}
