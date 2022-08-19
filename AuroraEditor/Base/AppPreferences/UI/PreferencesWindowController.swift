//
//  PreferencesWindowController.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 19/8/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

// Shows the feedback window model
final class PreferencesWindowController: NSWindowController, NSToolbarDelegate {
    convenience init<T: View>(view: T, size: NSSize) {
        let hostingController = NSHostingController(rootView: view)
        let window = NSWindow(contentViewController: hostingController)
        self.init(window: window)
        window.title = "Preferences"
        window.setContentSize(size)
        window.styleMask.insert(.fullSizeContentView)
        window.styleMask.remove(.resizable)
        window.titlebarSeparatorStyle = .none
    }

    override func showWindow(_ sender: Any?) {
        window?.center()
        window?.alphaValue = 0.0

        super.showWindow(sender)

        window?.animator().alphaValue = 1.0

        window?.collectionBehavior = [.transient, .ignoresCycle]
        window?.backgroundColor = .windowBackgroundColor

        feedbackToolbar()
    }

    private func feedbackToolbar() {
        let toolbar = NSToolbar(identifier: UUID().uuidString)
        toolbar.delegate = self
        toolbar.displayMode = .labelOnly
        self.window?.toolbarStyle = .unifiedCompact
        self.window?.toolbar = toolbar
    }

    func closeAnimated() {
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.duration = 0.4
        NSAnimationContext.current.completionHandler = {
            self.close()
        }
        window?.animator().alphaValue = 0.0
        NSAnimationContext.endGrouping()
    }
}
