//
//  INotificationService .swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// The `INotificationService` protocol defines methods and properties for managing notifications.
protocol INotificationService {
    /// A flag indicating whether "Do Not Disturb" mode is enabled.
    /// Enabling DND mode will result in all info and warning notifications being silent.
    var doNotDisturbMode: Bool { get set }

    /// Notifies the user with the provided notification.
    ///
    /// - Parameter notification: The `INotification` to be displayed.
    /// - Returns: An `INotificationHandle` that can be used to control the notification.
    func notify(notification: INotification)

    /// A convenient way to report informational messages.
    ///
    /// - Parameters:
    ///   - title: The title of the informational notification.
    ///   - message: The message associated with the informational notification.
    func info(title: String, message: String)

    /// A convenient way to report warning messages.
    ///
    /// - Parameters:
    ///   - title: The title of the warning notification.
    ///   - message: The message associated with the warning notification.
    func warn(title: String, message: String)

    /// A convenient way to report error messages.
    ///
    /// - Parameters:
    ///   - title: The title of the error notification.
    ///   - message: The message associated with the error notification.
    func error(title: String, message: String)
}
