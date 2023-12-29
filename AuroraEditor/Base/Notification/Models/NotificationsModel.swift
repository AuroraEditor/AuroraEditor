//
//  NotificationsModel.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import AppKit

/// The `NotificationsModel` manages notification-related data and settings.
class NotificationsModel: ObservableObject, INotificationsModel {
    /// A shared instance of the `NotificationsModel`.
    public static let shared: NotificationsModel = .init()

    /// The user's preferences for the app.
    public var preferences: AppPreferencesModel = .shared

    /// The filter applied to notifications.
    @Published
    public var filter: NotificationsFilter = .OFF

    /// A search query used to filter notifications by their content.
    @Published
    public var searchNotifications: String = ""

    /// An array of notifications currently managed by the model.
    @Published
    public var notifications: [INotification] = []

    /// A set to keep track of unique notification IDs.
    private var uniqueNotificationIDs = Set<String>()

    /// A flag indicating whether to show a notification toast.
    @Published
    @objc public dynamic var showNotificationToast: Bool = false

    /// A flag indicating whether the user is hovering over the notification toast.
    @Published
    public var hoveringOnToast: Bool = false

    /// The data for the notification toast, which is currently displayed.
    @Published
    public var notificationToastData: INotification = INotification(severity: .info,
                                                                    title: "",
                                                                    message: "",
                                                                    notificationType: .custom)

    /// Adds a notification to the notification manager, considering various conditions and settings.
    ///
    /// - Parameters:
    ///   - notification: The `INotification` to be added.
    func addNotification(notification: INotification) {
        // If notifications are not enabled, we should not allow sending any type of notification to the user.
        if !isNotificationsEnabled() {
            return
        }

        // We check if the user has the notification saved in their 'do not show again' list.
        // If they do, we don't add the notification until the user decides to remove it
        // from the list in settings.
        let notificationList = LocalStorage().listDoNotShowNotifications()
        if notificationList.contains(where: { $0.id == notification.id }) {
            Log.warning("This notification \(notification.id ?? "") has been marked by the user to not show again.")
            return
        }

        // In order to prevent a notification with the same contents or ID, we check if
        // the notification doesn't already exist. If it does, for whatever reason, we close
        // the notification and remove it from the list. If it does not exist, we continue as normal.
        if hasDuplicateNotification(notification: notification) {
            Log.error("Notification already exists")
            return
        }

        // TODO: Maybe give the user a choice as to what items show as a toast
        // if notification.severity == .info {
        //     notificationToastData = notification
        //     showNotificationToast = true
        // }

        // Set the notification data for the toast and enable displaying it.
        notificationToastData = notification
        showNotificationToast = true

        // Append the notification to the list of notifications.
        notifications.append(notification)
    }

    /// Sets the filter for notifications.
    ///
    /// - Parameter filter: The `NotificationsFilter` to apply to notifications.
    func setFilter(filter: NotificationsFilter) {
        self.filter = filter
    }

    /// A private utility function to check if a given notification has a duplicate ID.
    ///
    /// - Parameter notification: The notification to check for duplication.
    /// - Returns: `true` if the notification is a duplicate; otherwise, `false`.
    private func hasDuplicateNotification(notification: INotification) -> Bool {
        let notificationID = notification.id ?? ""

        // If the notification ID is already in the Set, it's a duplicate
        if uniqueNotificationIDs.contains(notificationID) {
            return true
        } else {
            // Otherwise, add it to the Set to keep track of unique IDs
            uniqueNotificationIDs.insert(notificationID)
            return false
        }
    }

    /// Checks whether or not the user has notifications enabled.
    ///
    /// - Returns: `true` if notifications are enabled; otherwise, `false`.
    func isNotificationsEnabled() -> Bool {
        return preferences.preferences.notifications.notificationsEnabled
    }

    /// Checks whether or not the user has "Do Not Disturb" (DND) enabled.
    ///
    /// Enabling DND stops all notifications, except `error` notifications, from showing unless they are disabled.
    ///
    /// - Returns: `true` if "Do Not Disturb" is enabled; otherwise, `false`.
    func isDoNotDisturbEnabled() -> Bool {
        return preferences.preferences.notifications.doNotDisturb
    }
}
