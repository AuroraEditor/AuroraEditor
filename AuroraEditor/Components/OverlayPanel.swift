//
//  OverlayPanel.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 20.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import AppKit

/// A panel that can be used as an overlay.
public final class OverlayPanel: NSPanel, NSWindowDelegate {
    /// The view type of the panel.
    var viewType: ViewType?

    /// The view of the panel.
    enum ViewType {
        /// The quick open view.
        case quickOpen

        /// The command palette view.
        case commandPalette
    }

    /// Initializes a new instance of the overlay panel.
    public init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 48),
            styleMask: [.fullSizeContentView, .titled, .resizable],
            backing: .buffered, defer: false)
        self.delegate = self
        self.center()
        self.titlebarAppearsTransparent = true
        self.isMovableByWindowBackground = true
    }

    /// Standard window button.
    /// 
    /// - Parameter button: The button type.
    /// - Returns: The button.
    override public func standardWindowButton(_ button: NSWindow.ButtonType) -> NSButton? {
        let btn = super.standardWindowButton(button)
        btn?.isHidden = true
        return btn
    }

    /// Window did resing key.
    /// 
    /// - Parameter notification: The notification.
    public func windowDidResignKey(_ notification: Notification) {
        if let panel = notification.object as? OverlayPanel {
            panel.close()
        }
    }
}
