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
        self.commandPaletteState = .init(possibleCommands: [])
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
        } else if item.isEnabled {
            Log.info("Item: \(item.title)")
            self.commandPaletteState?.possibleCommands.append(Command(name: "\(nameSoFar) \(item.title)", command: {
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
            }))
        }
    }
}
