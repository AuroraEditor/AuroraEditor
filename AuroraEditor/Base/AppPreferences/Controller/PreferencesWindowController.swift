//
//  PreferencesWindowController.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 19/8/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

// Shows the settings window model
final class PreferencesWindowController: NSWindowController, NSToolbarDelegate {
    convenience init<T: View>(view: T) {
        let hostingController = NSHostingController(rootView: view)
        let window = NSWindow(contentViewController: hostingController)
        self.init(window: window)
        window.title = "Preferences"
        window.styleMask.insert(.fullSizeContentView)
        window.titlebarSeparatorStyle = .none
    }

    override func showWindow(_ sender: Any?) {
        window?.center()
        window?.alphaValue = 0.0

        super.showWindow(sender)

        window?.animator().alphaValue = 1.0

        window?.collectionBehavior = [.transient, .ignoresCycle]
        window?.backgroundColor = .windowBackgroundColor

        settingsToolbar()
    }

    private func settingsToolbar() {
        let toolbar = NSToolbar(identifier: UUID().uuidString)
        toolbar.delegate = self
        toolbar.displayMode = .labelOnly
        self.window?.toolbarStyle = .unifiedCompact
        self.window?.toolbar = toolbar
    }

    func closeWindow() {
        NSApplication.shared.keyWindow?.close()
    }
}
