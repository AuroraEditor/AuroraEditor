//
//  NotificationsFilter.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

enum NotificationsFilter {

    /// No filter is enabled.
    case OFF

    /// All notifications are configured as silent.
    case SILENT

    /// All notifications are silent except error notifications.
    case ERROR
}
