//
//  NotificationPreferencesView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 07/02/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct NotificationPreferencesView: View {

    @ObservedObject
    private var appPreferences: AppPreferencesModel = .shared

    @ObservedObject
    private var notificationModel: NotificationsModel = .shared

    var body: some View {
        VStack(alignment: .leading) {
            Text("Notification Centre")
                .font(.system(size: 13,
                              weight: .semibold))
                .foregroundColor(.primary)

            // swiftlint:disable:next line_length
            Text("Notification Centre shows notifications ranging from account security, GitHub build actions state and even notifications from extensions")
                .foregroundColor(.secondary)
                .font(.system(size: 11))
                .multilineTextAlignment(.leading)
                .padding(.top, -8)

            GroupBox {
                // TODO: Show dialog before asking user if they wanna disable notifications
                HStackToggle(text: "Enable Notifications",
                             toggleValue: $appPreferences.preferences.notifications.notificationsEnabled)
                .onChange(of: appPreferences.preferences.notifications.notificationsEnabled) { _ in

                    // Since notifications are being disabled there should be
                    // no need to keep the old notifications still available in
                    // the notification centre. Thus we clean out the array removing
                    // any notifications that may have been present before disabling
                    // notifications.
                    notificationModel.notifications = []
                }
            }
            .padding(.top, 5)

            if appPreferences.preferences.notifications.notificationsEnabled {
                GroupBox {
                    HStackToggle(text: "Do not disturb mode",
                                 toggleValue: $appPreferences.preferences.notifications.doNotDisturb)

                    Divider()

                    HStackToggle(text: "Allow notifications on all profiles",
                                 toggleValue: $appPreferences.preferences.notifications.allProfiles)
                }
                .padding(.top, 5)
            }
        }
        .padding()
    }
}

struct NotificationPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationPreferencesView()
    }
}
