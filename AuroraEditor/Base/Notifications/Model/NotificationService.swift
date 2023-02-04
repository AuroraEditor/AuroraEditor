//
//  NotificationService.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 03/02/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

class NotificationService: INotificationService {

    private let model: NotificationsModel = .shared

    private let preferences: AppPreferencesModel = .shared

    init() {
        self.disturbMode = preferences.preferences.notifications.doNotDisturb

        updateDoNotDisturbFilters()
    }

    // MARK: - DND MODE

    private var disturbMode: Bool

    var doNotDisturbMode: Bool {
        get {
            disturbMode
        }

        set {
            if self.disturbMode == newValue {
                return
            }

            preferences.preferences.notifications.doNotDisturb = newValue
            self.disturbMode = newValue

            updateDoNotDisturbFilters()
        }
    }

    private func updateDoNotDisturbFilters() {
        let filter: NotificationsFilter

        if disturbMode {
            filter = .ERROR
        } else {
            filter = .OFF
        }

        // Set filter in the Notifications Model
        model.setFilter(filter: filter)
    }

    // MARK: - END DND REGION

    func notify(notification: INotification) {

        if notification.neverShowAgain != nil {
            let id = notification.neverShowAgain?.id ?? UUID().uuidString

            // TODO: Check if user already chose to not show the notification

            // TODO: Add notification actions
//            if !notification.neverShowAgain?.isSecondary {
//
//            } else {
//
//            }
        }

        model.addNotification(notification: notification)
    }

    func info(message: String) {
        model.addNotification(notification: INotification(id: UUID().uuidString,
                                                          severity: .info,
                                                          message: message,
                                                          notificationType: .system,
                                                          silent: false))
    }

    func warn(message: String) {
        model.addNotification(notification: INotification(id: UUID().uuidString,
                                                          severity: .warning,
                                                          message: message,
                                                          notificationType: .system,
                                                          silent: false))
    }

    func error(message: String) {
        model.addNotification(notification: INotification(id: UUID().uuidString,
                                                          severity: .error,
                                                          message: message,
                                                          notificationType: .system,
                                                          silent: false))
    }
}
