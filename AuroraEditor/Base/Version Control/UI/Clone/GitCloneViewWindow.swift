//
//  GitCloneViewWindow.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 5/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

extension GitCloneView {
    /// Helper function which opens welcome view
    static func openGitClientWindow() {
        let window = NSWindow(
            contentRect: .zero,
            styleMask: [.titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.center()

        let windowController = NSWindowController(window: window)

        var windowPath = "~/"

        window.contentView = NSHostingView(rootView: GitCloneView(
            shellClient: .live(),
            isPresented: .init(get: { true }, set: { newValue in
                if newValue == false {
                    windowController.window?.close()
                }
            }),
            repoPath: .init(get: { windowPath }, set: { newValue in
                windowPath = newValue
            }))
        )
        window.makeKeyAndOrderFront(self)
    }
}
