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
        window.styleMask.remove(.miniaturizable)
        window.styleMask.remove(.closable)
        window.styleMask.remove(.resizable)
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
    }
}
