//
//  WorkspaceDocument+Commands.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 2/9/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

extension WorkspaceDocument {
    // swiftlint:disable:next function_body_length
    func setupCommands() {
        self.commandPaletteState?.addCommands(commands: [
            // MARK: AuroraEditor menu
            Command(name: "About AurorEditor", command: {
                AppDelegate.openAboutWindow()
            }),
            Command(name: "Preferences", command: {
                if AppDelegate.tryFocusWindow(of: PreferencesView.self) { return }
                PreferencesView().showWindow()
            }),
            Command(name: "Hide AuroraEditor", command: {
                NSApplication.hide(NSApplication.shared)(self)
            }),
            Command(name: "Hide Others", command: {
                NSApplication.hideOtherApplications(NSApplication.shared)(self)
            }),
            Command(name: "Show All", command: {
                NSApplication.unhideAllApplications(NSApplication.shared)(self)
            }),
            Command(name: "Quit AuroraEditor", command: {
                NSApplication.shared.terminate(self)
            }),

            // MARK: File menu
            Command(name: "New", command: {
                NSDocumentController.newDocument(NSDocumentController.shared)(self)
            }),
            Command(name: "Open", command: {
                NSDocumentController.openDocument(NSDocumentController.shared)(self)
            }),
            Command(name: "Open Quickly", command: {
                self.broadcaster.broadcast(
                    sender: "AuroraEditor",
                    command: "openQuickly",
                    parameters: ["sender": "commandPalette"]
                )
            }),
            Command(name: "Save", command: {
                NSDocument.save(self)(self)
            }),
            Command(name: "Save As...", command: {
                NSDocument.saveAs(self)(self)
            }),
            Command(name: "Close", command: {
                self.broadcaster.broadcast(
                    sender: "AuroraEditor",
                    command: "close",
                    parameters: ["sender": "commandPalette"]
                )
            }),

            // MARK: View menu
            Command(name: "Toggle Toolbar", command: {
                self.broadcaster.broadcast(
                    sender: "AuroraEditor",
                    command: "toggleToolbarShown",
                    parameters: ["sender": "commandPalette"]
                )
            }),
            Command(name: "Customize Toolbar", command: {
                self.broadcaster.broadcast(
                    sender: "AuroraEditor",
                    command: "runToolbarCustomization",
                    parameters: ["sender": "commandPalette"]
                )
            }),
            Command(name: "Show Sidebar", command: {
                self.broadcaster.broadcast(
                    sender: "AuroraEditor",
                    command: "toggleSidebar",
                    parameters: ["sender": "commandPalette"]
                )
            }),
            Command(name: "Toggle Full Screen", command: {
                self.broadcaster.broadcast(
                    sender: "AuroraEditor",
                    command: "toggleFullScreen",
                    parameters: ["sender": "commandPalette"]
                )
            }),

            // TODO: Find and Navigate menus

            // MARK: Source Control menu
            Command(name: "Stash Changes", command: {
                self.data.showStashChangesSheet.toggle()
            }),
            Command(name: "Discard Project Changes", command: {
                self.broadcaster.broadcast(
                    sender: "AuroraEditor",
                    command: "discardProjectChanges",
                    parameters: ["sender": "commandPalette"]
                )
            }),

            // MARK: Window and Help menu
            Command(name: "Minimise", command: {
                self.broadcaster.broadcast(
                    sender: "AuroraEditor",
                    command: "miniaturize",
                    parameters: ["sender": "commandPalette"]
                )
            }),
            Command(name: "Zoom", command: {
                self.broadcaster.broadcast(
                    sender: "AuroraEditor",
                    command: "zoom",
                    parameters: ["sender": "commandPalette"]
                )
            }),
            Command(name: "Welcome Screen", command: {
                if AppDelegate.tryFocusWindow(of: WelcomeWindowView.self) { return }
                WelcomeWindowView.openWelcomeWindow()
            }),
            Command(name: "Give Feedback", command: {
                if AppDelegate.tryFocusWindow(of: FeedbackView.self) { return }
                FeedbackView().showWindow()
            }),

            // MARK: File creation/deletion, web tabs, tab closing
            Command(name: "Add File at Root", command: {
                guard let folderURL = self.fileSystemClient?.folderURL,
                      let root = try? self.fileSystemClient?.getFileItem(folderURL.path) else { return }
                root.addFile(fileName: "untitled")
            }),
            Command(name: "Add File at Selection", command: {
                self.broadcaster.broadcast(sender: "AuroraEditor", command: "newFileAtPos")
            }),
            Command(name: "Add Folder at Root", command: {
                guard let folderURL = self.fileSystemClient?.folderURL,
                      let root = try? self.fileSystemClient?.getFileItem(folderURL.path) else { return }
                root.addFolder(folderName: "untitled")
            }),
            Command(name: "Add Folder at Selection", command: {
                self.broadcaster.broadcast(sender: "AuroraEditor", command: "newDirAtPos")
            }),
            Command(name: "Open Web Tab", command: {
                self.openTab(item: WebTab(url: URL(string: "https://auroraeditor.com")))
            }),
            Command(name: "Close Current Tab", command: {
                if let currentTab = self.selectionState.selectedId {
                    self.closeTab(item: currentTab)
                }
            })
        ])
    }
}
