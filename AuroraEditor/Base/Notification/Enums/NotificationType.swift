//
//  NotificationType.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

enum NotificationType {

    /// System notifications, are notifications that is sent by AE.
    /// For example if there is an error in the users code the editor
    /// would use tthe system notification type.
    case system

    /// Extension notifications, are any notification that is being sent
    /// by an extension a user has installed.
    case extensionSystem

    /// A custom notification allows us to create a notification beyond just
    /// extension and system.
    case custom
}
