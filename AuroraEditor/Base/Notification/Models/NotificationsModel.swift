//
//  NotificationsModel.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import AppKit

class NotificationsModel: ObservableObject, INotificationsModel {

    public static let shared: NotificationsModel = .init()

    public var preferences: AppPreferencesModel = .shared

    @Published
    public var filter: NotificationsFilter = .OFF

    @Published
    public var searchNotifications: String = ""

    @Published
    public var notifications: [INotification] = []

    private var uniqueNotificationIDs = Set<String>()

    @Published
    public var showNotificationToast: Bool = false

    @Published
    public var hoveringOnToast: Bool = false

    @Published
    public var notificationToastData: INotification = INotification(severity: .info,
                                                                    title: "",
                                                                    message: "",
                                                                    notificationType: .custom)

    func addNotification(notification: INotification) {

        // If notifications are not enabled we should not allow sending
        // any type of notification to the user.
        if !isNotificationsEnabled() {
            return
        }

        // We check if the user has the notification saved in their `do not show again`
        // list, if they do we don't add the notification until the user decides to remove
        // the notification from not showing in settings.
        if let notificationID = notification.id, LocalStorage().listDoNotShowNotification().contains(notificationID) {
            Log.warning("This notification \(notificationID) has been marked by the user to not show again.")
            return
        }

        // In order to prevent a notification we the same contents or even id
        // we check if the notification doesn't first exist. If the notification
        // does for whatever reason exist we close the notification and remove it
        // from the list. If it does not exist, we continue as normal.
        if hasDuplicateNotification(notification: notification) {
            Log.error("Notification already exists")
            return
        }

        // TODO: Maybe give the user a choice as to what items show as a toast
//        if notification.severity == .info {
//            notificationToastData = notification
//
//            showNotificationToast = true
//        }

        notificationToastData = notification
        showNotificationToast = true

        notifications.append(notification)
    }

    func setFilter(filter: NotificationsFilter) {
        self.filter = filter
    }

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

    /// Checks whether or not the user has their notifications enabled and return the value.
    func isNotificationsEnabled() -> Bool {
        return preferences.preferences.notifications.notificationsEnabled
    }

    /// Checks whether or not the user has do not disturb enabled. Having dnd enabled will stop all
    /// notifications except `error` notifications from showing unless they are disabled.
    func isDoNotDisturbEnabled() -> Bool {
        return preferences.preferences.notifications.doNotDisturb
    }
}
