//
//  NotificationsNavigatorView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 03/02/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct NotificationsNavigatorView: View {

    @ObservedObject
    private var model: NotificationsModel = .shared

    @ObservedObject
    private var preferences: AppPreferencesModel = .shared

    var body: some View {
        VStack {
            if preferences.preferences.notifications.notificationsEnabled {
                if model.notifications.isEmpty {
                    VStack {
                        Text("No Notifications")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity,
                           maxHeight: .infinity)
                } else if filterResults().isEmpty ||
                            model.filter == .ERROR && model.notifications.filter({
                                $0.severity == .error }).isEmpty {
                    VStack {
                        Text("No Filter Results")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity,
                           maxHeight: .infinity)
                } else {
                    List(notificationList().reversed()) { notification in
                        NotificationViewItem(notification: notification)
                    }
                }
            } else {
                VStack {
                    // swiftlint:disable:next line_length
                    Text("Notifications has been disabled. Enable notifications in settings to continue receiving notifications.")
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity)
            }
        }
    }

    private func notificationList() -> [INotification] {
        if preferences.preferences.notifications.doNotDisturb {
            return model.notifications.filter({ $0.severity == .error })
        } else {
            if model.filter == .ERROR {
                return model.notifications.filter({ $0.severity == .error })
            } else {
                if !model.searchNotifications.isEmpty {
                    return filterResults()
                }
                return model.notifications
            }
        }
    }

    private func filterResults() -> [INotification] {
        return model.notifications.filter({ notification in
            model.searchNotifications.isEmpty ||
            notification.message.localizedStandardContains(model.searchNotifications)
        })
    }
}

struct NotificationsNavigatorView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsNavigatorView()
    }
}
