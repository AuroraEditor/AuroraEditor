//
//  NotificationsFilter.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

/// An enumeration specifying different types of filters for notifications.
enum NotificationsFilter {
    /// Represents that no filter is enabled, and all notifications should be displayed.
    case OFF

    /// Represents a filter where all notifications are configured as silent and not displayed to the user.
    case SILENT

    /// Represents a filter where all notifications are silent except error notifications.
    case ERROR
}
