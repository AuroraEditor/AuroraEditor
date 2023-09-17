//
//  INotificationsModel.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// The `INotificationsModel` protocol defines methods for managing notifications and filters.
protocol INotificationsModel {
    /// Adds a notification to the model.
    ///
    /// - Parameter notification: The `INotification` to be added.
    func addNotification(notification: INotification)

    /// Sets the filter for notifications.
    ///
    /// - Parameter filter: The `NotificationsFilter` to apply to notifications.
    func setFilter(filter: NotificationsFilter)
}
