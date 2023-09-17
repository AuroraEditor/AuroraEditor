//
//  NotificationIndicators.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The `NotificationIndicators` SwiftUI view displays notification indicators in the toolbar
/// based on the severity of notifications and user preferences.
struct NotificationIndicators: View {
    /// The shared instance of the `NotificationsModel`.
    @StateObject private var model: NotificationsModel = .shared

    /// The observed object for user preferences.
    @ObservedObject private var preferences: AppPreferencesModel = .shared

    /// The body of the view.
    var body: some View {
        // Display an error notification indicator button if there are error notifications.
        if let errorNotifications = filteredNotifications(severity: .error), !errorNotifications.isEmpty {
            ToolbarNotificationButtonView(
                notificationType: .error,
                notificationCount: errorNotifications.count
            )
        }

        // Display a warning notification indicator button if
        // there are warning notifications and "Do Not Disturb" mode
        // is not enabled.
        if !preferences.preferences.notifications.doNotDisturb,
           let warningNotifications = filteredNotifications(severity: .warning),
           !warningNotifications.isEmpty {
            ToolbarNotificationButtonView(
                notificationType: .warning,
                notificationCount: warningNotifications.count
            )
        }
    }

    /// Filters notifications based on severity and whether they are silent.
    ///
    /// - Parameter severity: The severity level to filter notifications.
    /// - Returns: An array of filtered notifications.
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
