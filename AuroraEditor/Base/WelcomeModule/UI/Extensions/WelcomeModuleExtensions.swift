//
//  Welcome.swift
//  AuroraEditor
//
//  Created by Nazar Rudnyk on 06.06.2022.
//

import SwiftUI
import Version_Control

extension WelcomeWindowView {

    /// Helper function which opens welcome view
    static func openWelcomeWindow(function: String = #function,
                                  file: String = #file,
                                  line: Int = #line) {
        Log.info("openWelcomeWindow is called from \(function) on \(line) in \(file)")
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 460),
            styleMask: [.titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.center()

        let windowController = NSWindowController(window: window)

        window.contentView = NSHostingView(rootView: WelcomeWindowView(
            shellClient: sharedShellClient.shellClient,
            openDocument: { url, opened in
                if let url = url {
                    AuroraEditorDocumentController.shared.openDocument(
                        withContentsOf: url,
                        display: true) { doc, _, _ in
                        if doc != nil {
                            opened()
                        }
                    }
                } else {
                    windowController.window?.close()
                    AuroraEditorDocumentController.shared.openDocument(
                        onCompletion: { _, _ in opened() },
                        onCancel: { WelcomeWindowView.openWelcomeWindow() }
                    )
                }
            },
            newDocument: {
                AuroraEditorDocumentController.shared.newDocument(nil)
            },
            dismissWindow: {
                windowController.window?.close()
            }
        ))
        window.makeKeyAndOrderFront(self)
    }
}
