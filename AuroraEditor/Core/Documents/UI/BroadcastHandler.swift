//
//  BroadcastHandler.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 09/07/2024.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

extension WorkspaceView {

    /// Broadcast handler
    ///
    /// This function parses and act on all broadcast messages sent to the editor.
    /// Whenever a broadcast is received this function will act on it (if needed)
    ///
    /// - Parameter broadcast: Broadcast message
    func broadcastHandler(broadcast: AuroraCommandBroadcaster.Broadcast) {
        // swiftlint:disable:previous function_body_length

        self.logger.info("\(broadcast.command)")
        extensionDynamic.name = broadcast.sender
        extensionDynamic.title = (broadcast.parameters["title"] as? String) ?? extensionDynamic.name

        if broadcast.command == "NOOP" {
            // Got a noop command, we can ignore this.
        } else if broadcast.command == "openSettings" {
            workspace.windowController?.openSettings()
        } else if broadcast.command == "showNotification" {
            notificationService.notify(
                notification: INotification(
                    id: UUID().uuidString,
                    severity: .info,
                    title: extensionDynamic.title,
                    message: (broadcast.parameters["message"] as? String) ?? "",
                    sender: broadcast.sender,
                    notificationType: .extensionSystem,
                    silent: false
                )
            )
        } else if broadcast.command == "showWarning" {
            notificationService.notify(
                notification: INotification(
                    id: UUID().uuidString,
                    severity: .warning,
                    title: extensionDynamic.title,
                    message: (broadcast.parameters["message"] as? String) ?? "",
                    sender: broadcast.sender,
                    notificationType: .extensionSystem,
                    silent: false
                )
            )
        } else if broadcast.command == "showError" {
            notificationService.notify(
                notification: INotification(
                    id: UUID().uuidString,
                    severity: .error,
                    title: extensionDynamic.title,
                    message: (broadcast.parameters["message"] as? String) ?? "",
                    sender: broadcast.sender,
                    notificationType: .extensionSystem,
                    silent: false
                )
            )
        } else if broadcast.command == "openSheet",
            let view = broadcast.parameters["view"] {
            extensionDynamic.view = AnyView(
                ExtensionCustomView(view: view, sender: broadcast.sender)
            )
            sheetIsOpened = true
        } else if broadcast.command == "openTab" {
            self.logger.info("openTab")
            workspace.openTab(
                item: ExtensionCustomViewModel(
                    name: extensionDynamic.title,
                    view: broadcast.parameters["view"],
                    sender: broadcast.sender
                )
            )
        } else if broadcast.command == "openWindow",
           let view = broadcast.parameters["view"] {
            let window = NSWindow()
            window.styleMask = NSWindow.StyleMask(rawValue: 0xf)
            window.contentViewController = NSHostingController(
                rootView: ExtensionCustomView(
                    view: view,
                    sender: broadcast.sender
                ).padding(5)
            )
            window.setFrame(
                NSRect(x: 700, y: 200, width: 500, height: 500),
                display: false
            )
            let windowController = NSWindowController()
            windowController.contentViewController = window.contentViewController
            windowController.window = window
            windowController.window?.title = extensionDynamic.title
            windowController.showWindow(self)
        } else {
            self.logger.info("Unknown broadcast command \(broadcast.command)")
        }
    }
}
