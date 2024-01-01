//
//  NotificationService.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

// The `NotificationManager` class manages notification-related settings and "Do Not Disturb" mode.
class NotificationService: INotificationService {

    /// A shared instance of the `NotificationsModel`.
    private let model: NotificationsModel = .shared

    /// A shared instance of user preferences for the app.
    private let preferences: AppPreferencesModel = .shared

    /// Initializes a new instance of `NotificationManager`.
    init() {
        // Initialize the disturbMode based on user preferences.
        self.disturbMode = preferences.preferences.notifications.doNotDisturb

        // Update the notification filters based on the initial disturbMode.
        updateDoNotDisturbFilters()
    }

    // MARK: - Do Not Disturb (DND) Mode

    /// A flag indicating whether "Do Not Disturb" mode is active.
    private var disturbMode: Bool

    /// A property to control "Do Not Disturb" mode.
    var doNotDisturbMode: Bool {
        get {
            return disturbMode
        }

        set {
            // Only proceed if the new value is different from the current value.
            if self.disturbMode == newValue {
                return
            }

            // Update the user preferences with the new disturb mode value.
            preferences.preferences.notifications.doNotDisturb = newValue
            self.disturbMode = newValue

            // Update the notification filters based on the new disturb mode.
            updateDoNotDisturbFilters()
        }
    }

    /// Updates the notification filters based on the current state of "Do Not Disturb" mode.
    private func updateDoNotDisturbFilters() {
        var filter: NotificationsFilter

        if disturbMode {
            // When "Do Not Disturb" mode is active, only show error notifications.
            filter = .ERROR
        } else {
            // When "Do Not Disturb" mode is inactive, turn off the filter.
            filter = .OFF
        }

        // Set the calculated filter in the Notifications Model.
        model.setFilter(filter: filter)
    }

    // MARK: - END DND REGION

    /// Notifies the user with the provided notification and handles special cases.
    ///
    /// - Parameter notification: The `INotification` to notify the user with.
    func notify(notification: INotification) {
        if notification.neverShowAgain != nil {
            let id = notification.neverShowAgain?.id ?? UUID().uuidString

            // TODO: Check if the user has previously chosen not to show the notification.
            // TODO: Add notification actions.
            Log.info(id)
        }

        // Add the notification to the model.
        model.addNotification(notification: notification)
    }

    /// Adds an informational notification to the notifications model.
    ///
    /// - Parameters:
    ///   - title: The title of the informational notification.
    ///   - message: The message associated with the informational notification.
    func editorUpdate(title: String, message: String) {
        model.addNotification(notification: INotification(id: "AuroraEditor-Update",
                                                          severity: .info,
                                                          title: title,
                                                          message: message,
                                                          notificationType: .update,
                                                          silent: false))
    }

    /// Adds an informational notification to the notifications model.
    ///
    /// - Parameters:
    ///   - title: The title of the informational notification.
    ///   - message: The message associated with the informational notification.
    func info(title: String, message: String) {
        model.addNotification(notification: INotification(id: UUID().uuidString,
                                                          severity: .info,
                                                          title: title,
                                                          message: message,
                                                          notificationType: .system,
                                                          silent: false))
    }

    /// Adds a warning notification to the notifications model.
    ///
    /// - Parameters:
    ///   - title: The title of the warning notification.
    ///   - message: The message associated with the warning notification.
    func warn(title: String, message: String) {
        model.addNotification(notification: INotification(id: UUID().uuidString,
                                                          severity: .warning,
                                                          title: title,
                                                          message: message,
                                                          notificationType: .system,
                                                          silent: false))
    }

    /// Adds an error notification to the notifications model.
    ///
    /// - Parameters:
    ///   - title: The title of the error notification.
    ///   - message: The message associated with the error notification.
    func error(title: String, message: String) {
        model.addNotification(notification: INotification(id: UUID().uuidString,
                                                          severity: .error,
                                                          title: title,
                                                          message: message,
                                                          notificationType: .system,
                                                          silent: false))
    }
}
