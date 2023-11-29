//
//  AboutWindowHostingController.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/09.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

// This class helps display the AboutView
final class AboutWindowHostingController<T: View>: NSWindowController {

    private var escapeDetectEvent: Any?

    init(view: T, size: NSSize) {
        let hostingController = NSHostingController(rootView: view)
        let window = NSWindow(contentViewController: hostingController)
        super.init(window: window)

        configureWindow(size: size)
        setupEscapeKeyEventHandler()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureWindow(size: NSSize) {
        guard let window = window else { return }

        window.setContentSize(size)
        window.styleMask.subtract([.resizable, .miniaturizable])
        window.styleMask.insert(.fullSizeContentView)
        window.alphaValue = 0.5
        window.collectionBehavior = [.transient, .ignoresCycle]
        window.isMovableByWindowBackground = true
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
    }

    private func setupEscapeKeyEventHandler() {
        escapeDetectEvent = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 {
                self?.closeAnimated()
                return nil
            }
            return event
        }
    }

    override func showWindow(_ sender: Any?) {
        window?.center()
        super.showWindow(sender)
        window?.makeKeyAndOrderFront(nil)
        animateWindow(toAlpha: 1.0)
    }

    deinit {
        Log.info("About Window controller de-init'd")
        removeEscapeKeyEventHandler()
    }

    private func removeEscapeKeyEventHandler() {
        if let escapeDetectEvent = escapeDetectEvent {
            NSEvent.removeMonitor(escapeDetectEvent)
            self.escapeDetectEvent = nil
        }
    }

    func closeAnimated() {
        animateWindow(toAlpha: 0.0) {
            self.close()
        }
    }

    private func animateWindow(toAlpha alphaValue: CGFloat, completion: (() -> Void)? = nil) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.4
            window?.animator().alphaValue = alphaValue
        } completionHandler: {
            completion?()
        }
    }
}
