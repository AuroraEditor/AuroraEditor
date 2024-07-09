//
//  ToolbarAppInfoViewController.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 10/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Cocoa
import SwiftUI

/// Toolbar app info view controller.
class ToolbarAppInfoViewController: NSViewController {

    /// Notification service
    private let notificationService: NotificationService = .init()

    /// Notification model
    private let notificationModel: NotificationsModel = .shared

    /// App name label
    @IBOutlet
    var appNameLabel: NSTextField!

    /// Build status label
    @IBOutlet
    var buildStatusLabel: NSTextField!

    /// Time label
    @IBOutlet
    var timeLabel: NSTextField!

    /// View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        appNameLabel.stringValue = "AuroraEditor"
        buildStatusLabel.stringValue = "Build Succeeded"
        timeLabel.stringValue = "Today at " + getTime()
    }

    /// Get the current time.
    /// 
    /// - Returns: The current time.
    func getTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }

    /// App info button clicked
    /// 
    /// - Parameter sender: The sender.
    @IBAction
    func appInfoClicked(_ sender: Any) {
        // Handle app info button click
        notificationService.notify(notification: INotification(
            id: "121DD622-1624-4AF7-ADF7-528F81512925",
            severity: .info,
            title: "Info Notification",
            message: "This is a test",
            sender: "Toolbar App Info View Controller",
            notificationType: .system
        ))
    }
}

/// Toolbar app info view.
class ToolbarAppInfoView: NSView {

    /// Active state
    private var activeState: ControlActiveState = .inactive // TODO: Implement ControlActiveState

    /// Notification service
    private let notificationService: NotificationService = .init()

    /// Notification model
    private let notificationModel: NotificationsModel = .shared

    /// Get the current time.
    /// 
    /// - Returns: The current time.
    func getTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }

    /// Draw the view.
    /// 
    /// - Parameter dirtyRect: The dirty rect.
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Draw your custom view here
        let labelHeight: CGFloat = 16
        let labelFont = NSFont.systemFont(ofSize: 11)
        let labelColor = NSColor.labelColor

        // Draw the app name
        let appNameRect = NSRect(x: 5, y: bounds.height - labelHeight - 5, width: 100, height: labelHeight)
        let appNameAttrs: [NSAttributedString.Key: Any] = [.font: labelFont, .foregroundColor: labelColor]
        let appNameString = NSAttributedString(string: "AuroraEditor", attributes: appNameAttrs)
        appNameString.draw(in: appNameRect)

        // Draw the build status
        let buildStatusRect = NSRect(x: appNameRect.maxX + 10,
                                     y: bounds.height - labelHeight - 5,
                                     width: 100,
                                     height: labelHeight)
        let buildStatusAttrs: [NSAttributedString.Key: Any] = [.font: labelFont, .foregroundColor: labelColor]
        let buildStatusString = NSAttributedString(string: "Build Succeeded", attributes: buildStatusAttrs)
        buildStatusString.draw(in: buildStatusRect)

        // Draw the time
        let timeRect = NSRect(x: buildStatusRect.maxX + 10,
                              y: bounds.height - labelHeight - 5,
                              width: 150,
                              height: labelHeight)
        let timeAttrs: [NSAttributedString.Key: Any] = [.font: labelFont, .foregroundColor: labelColor]
        let timeString = NSAttributedString(string: "Today at " + getTime(), attributes: timeAttrs)
        timeString.draw(in: timeRect)

        // Draw the app icon (if needed)
        let appIconRect = NSRect(x: 5, y: 5, width: 16, height: 16)
        if let appIcon = NSImage(named: "app.dashed") {
            appIcon.draw(in: appIconRect)
        }

        // Draw the chevron icon (if needed)
        let chevronIconRect = NSRect(x: appIconRect.maxX + 5, y: 5, width: 16, height: 16)
        if let chevronIcon = NSImage(named: "chevron.right") {
            chevronIcon.draw(in: chevronIconRect)
        }
    }

    /// Mouse down event.
    /// 
    /// - Parameter event: The event.
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        // Handle mouse click events here
        if event.clickCount == 1 {
            // Single click action
            notificationService.notify(notification: INotification(
                id: "121DD622-1624-4AF7-ADF7-528F81512925",
                severity: .info,
                title: "Info Notification",
                message: "This is a test",
                sender: "Toolbar App Info View",
                notificationType: .system
            ))
        }
    }
}
