//
//  WorkspaceDocument+Commands.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 2/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

extension WorkspaceDocument {
    // swiftlint : disable : next function_body_length
    func setupCommands() {
//        self.commandPaletteState?.addCommands(commands: [
//            // MARK: AuroraEditor menu
//            Command(name: "About AurorEditor", command: {
//                if AppDelegate.tryFocusWindow(of: AboutView.self) { return }
//                AboutView().showWindow(width: 530, height: 220)
//            }),
//            Command(name: "Preferences", command: {
//                if AppDelegate.tryFocusWindow(of: PreferencesView.self) { return }
//                PreferencesView().showWindow()
//            }),
//            Command(name: "Hide AuroraEditor", command: {
//                NSApplication.hide(NSApplication.shared)(self)
//            }),
//            Command(name: "Hide Others", command: {
//                NSApplication.hideOtherApplications(NSApplication.shared)(self)
//            }),
//            Command(name: "Show All", command: {
//                NSApplication.unhideAllApplications(NSApplication.shared)(self)
//            }),
//            Command(name: "Quit AuroraEditor", command: {
//                NSApplication.shared.terminate(self)
//            }),
//
//            // MARK: File menu
//            Command(name: "New", command: {
//                NSDocumentController.newDocument(NSDocumentController.shared)(self)
//            }),
//            Command(name: "Open", command: {
//                NSDocumentController.openDocument(NSDocumentController.shared)(self)
//            }),
//            Command(name: "Open Quickly", command: {
//                self.windowController?.openQuickly(self)
//            }),
//            Command(name: "Save", command: {
//                NSDocument.save(self)(self)
//            }),
//            Command(name: "Save As...", command: {
//                NSDocument.saveAs(self)(self)
//            }),
//            Command(name: "Close", command: {
//                self.windowController?.close()
//            }),
//
//            // MARK: View menu
//            Command(name: "Toggle Toolbar", command: {
//                self.windowController?.window?.toggleToolbarShown(self)
//            }),
//            Command(name: "Customize Toolbar", command: {
//                self.windowController?.window?.runToolbarCustomizationPalette(self)
//            }),
//            Command(name: "Show Sidebar", command: {
//                self.windowController?.splitViewController.toggleSidebar(self)
//            }),
//            Command(name: "Toggle Full Screen", command: {
//                self.windowController?.window?.toggleFullScreen(self)
//            }),
//
//            // TODO: Find and Navigate menus
//
//            // MARK: Source Control menu
//            Command(name: "Stash Changes", command: {
//                self.showStashChangesSheet.toggle()
//            }),
//            Command(name: "Discard Project Changes", command: {
//                self.windowController?.discardProjectChanges(self)
//            }),
//
//            // MARK: Window and Help menu
//            Command(name: "Minimise", command: {
//                self.windowController?.window?.miniaturize(self)
//            }),
//            Command(name: "Zoom", command: {
//                self.windowController?.window?.zoom(self)
//            }),
//            Command(name: "Welcome Screen", command: {
//                if AppDelegate.tryFocusWindow(of: WelcomeWindowView.self) { return }
//                WelcomeWindowView.openWelcomeWindow()
//            }),
//            Command(name: "Give Feedback", command: {
//                if AppDelegate.tryFocusWindow(of: FeedbackView.self) { return }
//                FeedbackView().showWindow()
//            }),
//
//            // MARK: File creation/deletion, web tabs, tab closing
//            Command(name: "Add File at Root", command: {
//                guard let folderURL = self.fileSystemClient?.folderURL,
//                      let root = try? self.fileSystemClient?.getFileItem(folderURL.path) else { return }
//                root.addFile(fileName: "untitled")
//            }),
//            Command(name: "Add Folder at Root", command: {
//                guard let folderURL = self.fileSystemClient?.folderURL,
//                      let root = try? self.fileSystemClient?.getFileItem(folderURL.path) else { return }
//                root.addFolder(folderName: "untitled")
//            }),
//            Command(name: "Open Web Tab", command: {
//                self.openTab(item: WebTab(url: URL(string: "https://auroraeditor.com")))
//            }),
//            Command(name: "Close Current Tab", command: {
//                if let currentTab = self.selectionState.selectedId {
//                    self.closeTab(item: currentTab)
//                }
//            })
//        ])
    }
}
