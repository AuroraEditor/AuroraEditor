//
//  NotificationChangeType.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

/// An enumeration representing different types of changes that can occur to notifications.
enum NotificationChangeType {
    /// Indicates that a new notification was added.
    case ADD

    /// Indicates that an existing notification has changed. Additional information can be found
    /// in the `detail` property of the event.
    case CHANGE

    /// Indicates that a notification was removed.
    case REMOVE
}
