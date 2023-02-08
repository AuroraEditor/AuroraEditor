//
//  NotificationsModel.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 03/02/2023.
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

    func addNotification(notification: INotification) {

        // If notifications are not enabled we should not allow sending
        // any type of notification to the user.
        if !isNotificationsEnabled() {
            return
        }

        // In order to prevent a notification we the same contents or even id
        // we check if the notification doesn't first exist. If the notification
        // does for whatever reason exist we close the notification and remove it
        // from the list. If it does not exist, we continue as normal.
        if findNotification(notification: notification) {
            Log.error("Notification already exists")
        }

        notifications.append(notification)
    }

    func setFilter(filter: NotificationsFilter) {
        self.filter = filter
    }

    private func findNotification(notification: INotification) -> Bool {
        return notifications.filter({ $0.id == notification.id }).count > 1
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
