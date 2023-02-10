//
//  INotification.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 03/02/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

struct INotification: INotificationProperties, Equatable, Hashable, Identifiable {

    /// The id of the notification. If provided, will be used to compare
    /// notifications with others to decide whether a notification is
    /// duplicate or not.
    var id: String? = UUID().uuidString

    /// The severity of the notification. Either `Info`, `Warning` or `Error`.
    var severity: Severity

    /// The notification icon
    var icon: URL?

    /// The title of the notification.
    var title: String

    /// The message of the notification. This can either be a `string` or `Error`
    /// string format.
    var message: String

    /// The type of notification that is being sent to the editor.
    var notificationType: NotificationType

    /// The issue type when being sent from the editor itself.
    var issueType: IssueType?

    /// Silent notifications are not shown to the user unless the notification center
    /// is opened. The status bar will still indicate all number of notifications to
    /// catch some attention.
    var silent: Bool?

    /// Adds an action to never show the notification again. The choice will be persisted
    /// such as future requests will not cause the notification to show again.
    var neverShowAgain: INeverShowAgainOptions?
}
