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
            if model.notifications.isEmpty {
                VStack {
                    Text("No Notifications")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity)
            } else {
                List(notificationList()) { notification in
                    NotificationViewItem(notification: notification)
                }
            }
        }
    }

    private func isDoNotDisturbEnabled() -> Bool {
        return preferences.preferences.notifications.doNotDisturb
    }

    private func notificationList() -> [INotification] {
        if isDoNotDisturbEnabled() {
            return model.notifications.filter({ $0.severity == .error })
        } else {
            if model.filter == .ERROR {
                return model.notifications.filter({ $0.severity == .error })
            }

            return model.notifications
        }
    }
}

struct NotificationsNavigatorView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsNavigatorView()
    }
}
