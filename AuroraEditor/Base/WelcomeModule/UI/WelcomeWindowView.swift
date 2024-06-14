//
//  WelcomeWindowView.swift
//  Aurora Editor
//
//  Created by Ziyuan Zhao on 2022/3/18.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Version_Control

/// The main window when opening Aurora Editor when there
public struct WelcomeWindowView: View {
    /// Open document closure
    private let openDocument: (URL?, @escaping () -> Void) -> Void

    /// New document closure
    private let newDocument: () -> Void

    /// Dismiss window closure
    private let dismissWindow: () -> Void

    /// Shell client
    private let shellClient: ShellClient

    /// Initialize a new WelcomeWindowView
    /// 
    /// - Parameter shellClient: shell client
    /// - Parameter openDocument: open document closure
    /// - Parameter newDocument: new document closure
    /// - Parameter dismissWindow: dismiss window closure
    /// 
    /// - Returns: a new WelcomeWindowView
    public init(
        shellClient: ShellClient,
        openDocument: @escaping (URL?, @escaping () -> Void) -> Void,
        newDocument: @escaping () -> Void,
        dismissWindow: @escaping () -> Void
    ) {
        self.shellClient = shellClient
        self.openDocument = openDocument
        self.newDocument = newDocument
        self.dismissWindow = dismissWindow
    }

    /// The view body.
    public var body: some View {
        ZStack {
            Button("_") { // Do not empty the text, this will break functionality
                self.dismissWindow()
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.escape, modifiers: [])
            .focusable(false)

            Button("_") { // Do not empty the text, this will break functionality
                self.dismissWindow()
            }
            .buttonStyle(.plain)
            .keyboardShortcut("w", modifiers: [.command])
            .focusable(false)

            HStack(spacing: 0) {
                WelcomeView(
                    shellClient: shellClient,
                    openDocument: openDocument,
                    newDocument: newDocument,
                    dismissWindow: dismissWindow
                )
                RecentProjectsView(
                    openDocument: openDocument,
                    dismissWindow: dismissWindow
                )
            }
            .edgesIgnoringSafeArea(.top)
        }
    }
}
