//
//  CrashReportController.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/07/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

import SwiftUI

// This class helps display the Crash Reporting view before termination.
final class CrashReportController: NSWindowController, NSToolbarDelegate {
    convenience init<T: View>(view: T) {
        let hostingController = NSHostingController(rootView: view)
        let window = NSWindow(contentViewController: hostingController)
        self.init(window: window)
        window.title = "📋 Problem Report for AuroraEditor"
        window.styleMask.remove(.resizable)
        window.styleMask.remove(.closable)
        window.styleMask.remove(.miniaturizable)
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
