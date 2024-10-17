//
//  AboutWindowHostingController.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/09.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import OSLog

// This class helps display the AboutView
final class AboutWindowHostingController<T: View>: NSWindowController, Sendable {

    /// The event handler for the escape key
    private var escapeDetectEvent: Any?

    /// Logger
    let logger = Logger(subsystem: "com.auroraeditor", category: "About window hosting controller")

    /// Initializes the window controller with the given view and size
    /// 
    /// - Parameter view: The view to display in the window
    /// - Parameter size: The size of the window
    init(view: T, size: NSSize) {
        let hostingController = NSHostingController(rootView: view)
        let window = NSWindow(contentViewController: hostingController)
        super.init(window: window)

        configureWindow(size: size)
        setupEscapeKeyEventHandler()
    }

    /// Required initializer
    /// 
    /// - Parameter coder: The coder
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Configures the window with the given size
    /// 
    /// - Parameter size: The size of the window
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

    /// Sets up the event handler for the escape key
    private func setupEscapeKeyEventHandler() {
        escapeDetectEvent = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 {
                self?.closeAnimated()
                return nil
            }
            return event
        }
    }

    /// Shows the window
    /// 
    /// - Parameter sender: The sender
    override func showWindow(_ sender: Any?) {
        window?.center()
        super.showWindow(sender)
        window?.makeKeyAndOrderFront(nil)
        animateWindow(toAlpha: 1.0)
    }

    /// De-initializes the window controller
    deinit {
        logger.info("About Window controller de-init'd")
        removeEscapeKeyEventHandler()
    }

    /// Removes the escape key event handler
    private func removeEscapeKeyEventHandler() {
        if let escapeDetectEvent = escapeDetectEvent {
            NSEvent.removeMonitor(escapeDetectEvent)
            self.escapeDetectEvent = nil
        }
    }

    /// Closes the window
    func closeAnimated() {
        animateWindow(toAlpha: 0.0) {
            self.close()
        }
    }

    /// Animates the window to the given alpha value
    /// 
    /// - Parameter alphaValue: The alpha value
    /// - Parameter completion: The completion handler
    private func animateWindow(toAlpha alphaValue: CGFloat, completion: (() -> Void)? = nil) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.4
            window?.animator().alphaValue = alphaValue
        } completionHandler: {
            completion?()
        }
    }
}
