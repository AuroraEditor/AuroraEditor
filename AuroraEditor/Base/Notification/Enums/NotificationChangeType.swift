//
//  NotificationChangeType.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

enum NotificationChangeType {

    /// A notification was added.
    case ADD

    /// A notification changed. Check `detail` property
    /// on the event for additional information.
    case CHANGE

    /// A notification was removed.
    case REMOVE
}
