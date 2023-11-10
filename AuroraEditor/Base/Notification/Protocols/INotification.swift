//
//  INotification.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// The `INotification` struct represents a notification with various properties.
struct INotification: INotificationProperties, Equatable, Hashable, Identifiable, Codable {
    /// The unique identifier for the notification. Used to determine if a notification is a duplicate.
    var id: String = UUID().uuidString

    /// The severity of the notification. It can be one of the following: `Info`, `Warning`, or `Error`.
    var severity: Severity

    /// The URL of the notification icon, if applicable.
    var icon: URL?

    /// The title of the notification.
    var title: String

    /// The message of the notification. This can be either a simple string or an error string format.
    var message: String

    /// The type of notification.
    var notificationType: NotificationType

    /// The issue type when the notification originates from the editor itself.
    var issueType: IssueType?

    /// A flag indicating whether the notification should be shown silently.
    ///
    /// Silent notifications are not displayed as alerts but may be indicated in the status bar
    /// to catch the user's attention.
    var silent: Bool?

    /// Options to configure whether the notification should never be shown again.
    ///
    /// By adding an action to never show the notification again, the user's choice will
    /// be persisted, and future requests will not cause the notification to appear.
    var neverShowAgain: INeverShowAgainOptions?
}
