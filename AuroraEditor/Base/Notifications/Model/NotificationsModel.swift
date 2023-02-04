//
//  NotificationsModel.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 03/02/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

class NotificationsModel: ObservableObject, INotificationsModel {

    public static let shared: NotificationsModel = .init()

    @Published
    public var filter: NotificationsFilter = .OFF

    @Published
    public var notifications: [INotification] = []

    func addNotification(notification: INotification) {

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
}
