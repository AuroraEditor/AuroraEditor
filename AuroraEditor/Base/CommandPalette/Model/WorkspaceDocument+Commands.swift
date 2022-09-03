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
    func setupCommands() {
        self.commandPaletteState?.addCommands(commands: [
            Command(name: "Open Quickly", command: {
                Log.info("Opening Quickly")
                self.windowController?.openQuickly(self)
            }),
            Command(name: "Stash Changes", command: {
                Log.info("Stashed Changes")
                self.windowController?.stashChangesItems(self)
            }),
            Command(name: "Discard Project Changes", command: {
                Log.info("Discarding Project Changes")
                self.windowController?.discardProjectChanges(self)
            }),
            Command(name: "Open Preferences", command: {
                Log.info("Opening Preferences")
                if self.tryFocusWindow(of: PreferencesView.self) { return }
                PreferencesView().showWindow()
            }),
            Command(name: "Open About Page", command: {
                Log.info("Opening About")
                if self.tryFocusWindow(of: AboutView.self) { return }
                AboutView().showWindow(width: 530, height: 220)
            }),
            Command(name: "Open Welcome Screen", command: {
                Log.info("Opening Welcome Screen")
                if self.tryFocusWindow(of: WelcomeWindowView.self) { return }
                WelcomeWindowView.openWelcomeWindow()
            }),
            Command(name: "Open Feedback Page", command: {
                Log.info("Opening Feedback")
                if self.tryFocusWindow(of: FeedbackView.self) { return }
                FeedbackView().showWindow()
            }),
            Command(name: "Stash Changes", command: {
                Log.info("Stashed Changes")
                self.windowController?.stashChangesItems(self)
            }),
            Command(name: "Discard Project Changes", command: {
                Log.info("Discarding Project Changes")
                self.windowController?.discardProjectChanges(self)
            }),
            Command(name: "Open Preferences", command: {
                Log.info("Opening Preferences")
                if self.tryFocusWindow(of: PreferencesView.self) { return }
                PreferencesView().showWindow()
            }),
            Command(name: "Open About Page", command: {
                Log.info("Opening About")
                if self.tryFocusWindow(of: AboutView.self) { return }
                AboutView().showWindow(width: 530, height: 220)
            }),
            Command(name: "Open Welcome Screen", command: {
                Log.info("Opening Welcome Screen")
                if self.tryFocusWindow(of: WelcomeWindowView.self) { return }
                WelcomeWindowView.openWelcomeWindow()
            }),
        ])
        for item in NSApplication.shared.mainMenu?.items ?? [] {
            addMenuItemAsCommand(item: item)
        }
    }

    /// Tries to focus a window with specified view content type.
    /// - Parameter type: The type of viewContent which hosted in a window to be focused.
    /// - Returns: `true` if window exist and focused, oterwise - `false`
    private func tryFocusWindow<T: View>(of type: T.Type) -> Bool {
        guard let window = NSApp.windows.filter({ ($0.contentView as? NSHostingView<T>) != nil }).first
        else { return false }

        window.makeKeyAndOrderFront(self)
        return true
    }

    private func addMenuItemAsCommand(item: NSMenuItem, nameSoFar: String = "") {
        if let submenu = item.submenu {
            for subItem in submenu.items {
                addMenuItemAsCommand(item: subItem, nameSoFar: "\(item.title) ->")
            }
        } else {
            self.commandPaletteState?.addCommand(command: Command(name: "\(nameSoFar) \(item.title)", command: {
                if let action = item.action {
                    if let target = item.target {
                        Log.info("Action for \(item.title) executed by target")
                        _ = target.perform(action)
                    } else if let window = self.windowController?.window {
                        Log.info("Action for \(item.title) executed by window")
                        window.perform(action)
                    } else {
                        Log.info("Action for \(item.title) executed by self")
                        self.perform(action)
                    }
                }
            }, isEnabled: item.isEnabled && item.action != nil))
        }
    }
}
