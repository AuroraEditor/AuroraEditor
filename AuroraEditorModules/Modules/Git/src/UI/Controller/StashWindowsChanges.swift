//
//  StashWindowsChanges.swift
//  
//
//  Created by Nanashi Li on 2022/07/13.
//

import Foundation

import SwiftUI

final class StashWindowsChanges: NSWindowController, NSToolbarDelegate {
    convenience init<T: View>(view: T) {
        let hostingController = NSHostingController(rootView: view)
        let window = NSPanel(contentViewController: hostingController)
        self.init(window: window)
        window.isMovable = false
        window.isMovableByWindowBackground = false
        window.beginSheet(window)
    }

    override func showWindow(_ sender: Any?) {
        window?.center()
        window?.alphaValue = 0.0

        super.showWindow(sender)

        window?.animator().alphaValue = 1.0
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
