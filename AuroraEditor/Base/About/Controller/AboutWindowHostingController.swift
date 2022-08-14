//
//  AboutWindowHostingController.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/09.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

// This class helps display the AboutView
final class AboutWindowHostingController: NSWindowController {
    convenience init<T: View>(view: T, size: NSSize) {
        let hostingController = NSHostingController(rootView: view)
        // New window holding our SwiftUI view
        let window = NSWindow(contentViewController: hostingController)
        self.init(window: window)
        window.setContentSize(size)
        window.styleMask.remove(.resizable)
        window.styleMask.insert(.fullSizeContentView)
        window.alphaValue = 0.5
        window.styleMask.remove(.miniaturizable)
    }

    private var escapeDetectEvent: Any?

    override func showWindow(_ sender: Any?) {
        window?.center()
        window?.alphaValue = 0.0

        super.showWindow(sender)

        window?.animator().alphaValue = 1.0

        // Close the window when the escape key is pressed
        escapeDetectEvent = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard event.keyCode == 53 else { return event }

            self.closeAnimated()

            return nil
        }

        window?.collectionBehavior = [.transient, .ignoresCycle]
        window?.isMovableByWindowBackground = true
        window?.titlebarAppearsTransparent = true
        window?.titleVisibility = .hidden
    }

    deinit {
        Log.info("About Window controller de-init'd")
        if let escapeDetectEvent = escapeDetectEvent {
            NSEvent.removeMonitor(escapeDetectEvent)
        }
    }

    func closeAnimated() {
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.duration = 0.4
        NSAnimationContext.current.completionHandler = {
            if let escapeDetectEvent = self.escapeDetectEvent {
                NSEvent.removeMonitor(escapeDetectEvent)
            }
            self.close()
        }
        window?.animator().alphaValue = 0.0
        NSAnimationContext.endGrouping()
    }
}
