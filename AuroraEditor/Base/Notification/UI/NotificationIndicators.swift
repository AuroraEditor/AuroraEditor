//
//  NotificationIndicators.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

///
struct NotificationIndicators: View {

    @StateObject
    private var model: NotificationsModel = .shared

    @ObservedObject
    private var preferences: AppPreferencesModel = .shared

    var body: some View {
        if let errorNotifications = filteredNotifications(severity: .error),
           !errorNotifications.isEmpty {
            ToolbarNotificationButtonView(
                notificationType: .error,
                notificationCount: errorNotifications.count
            )
        }

        if !preferences.preferences.notifications.doNotDisturb,
           let warningNotifications = filteredNotifications(severity: .warning),
           !warningNotifications.isEmpty {
            ToolbarNotificationButtonView(
                notificationType: .warning,
                notificationCount: warningNotifications.count
            )
        }
    }

    private func filteredNotifications(severity: Severity) -> [INotification]? {
        return model.notifications.filter {
            $0.severity == severity && !($0.silent ?? false)
        }
    }
}

struct NotificationIndicators_Previews: PreviewProvider {
    static var previews: some View {
        NotificationIndicators()
    }
}
