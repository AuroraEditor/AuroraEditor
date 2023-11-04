//
//  ToolbarAppInfoViewController.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 10/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Cocoa
import SwiftUI

class ToolbarAppInfoViewController: NSViewController {
    private let notificationService: NotificationService = .init()
    private let notificationModel: NotificationsModel = .shared

    @IBOutlet var appNameLabel: NSTextField!
    @IBOutlet var buildStatusLabel: NSTextField!
    @IBOutlet var timeLabel: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        appNameLabel.stringValue = "AuroraEditor"
        buildStatusLabel.stringValue = "Build Succeeded"
        timeLabel.stringValue = "Today at " + getTime()
    }

    func getTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }

    @IBAction func appInfoClicked(_ sender: Any) {
        // Handle app info button click
        notificationService.notify(notification: INotification(
            id: "121DD622-1624-4AF7-ADF7-528F81512925",
            severity: .info,
            title: "Info Notification",
            message: "This is a test",
            notificationType: .system
        ))
    }
}

class ToolbarAppInfoView: NSView {
    private var activeState: ControlActiveState = .inactive // Implement ControlActiveState
    private let notificationService: NotificationService = .init()
    private let notificationModel: NotificationsModel = .shared

    func getTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }

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
                notificationType: .system
            ))
        }
    }
}
