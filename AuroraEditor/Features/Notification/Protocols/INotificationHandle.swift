//
//  INotificationHandle.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// The `INotificationHandle` protocol defines methods for controlling and updating notifications.
protocol INotificationHandle {
    /// Updates the severity of the notification.
    ///
    /// - Parameter severity: The new severity level for the notification.
    func updateSeverity(severity: Severity)

    /// Updates the message of the notification even after it is already visible.
    ///
    /// - Parameter message: The new message to display in the notification.
    func updateMessage(message: String)

    /// Hides the notification and removes it from the notification center.
    func close()
}
