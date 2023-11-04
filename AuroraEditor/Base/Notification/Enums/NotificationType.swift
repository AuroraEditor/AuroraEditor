//
//  NotificationType.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

/// An enumeration specifying different types of notifications.
enum NotificationType: Codable {
    /// Represents system notifications sent by AE (the editor). For example, errors in user code.
    case system

    /// Represents update notifications sent by AE (the editor).
    case update

    /// Represents extension notifications sent by user-installed extensions.
    case extensionSystem

    /// Represents custom notifications that provide flexibility beyond system and extension notifications.
    case custom
}
