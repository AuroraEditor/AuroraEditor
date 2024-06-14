//
//  NotificationsNavigatorView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The view for the notifications navigator.
struct NotificationsNavigatorView: View {

    /// The notifications model
    @ObservedObject
    private var model: NotificationsModel = .shared

    /// The preferences model
    @ObservedObject
    private var preferences: AppPreferencesModel = .shared

    /// The view body.
    var body: some View {
        VStack {
            if preferences.preferences.notifications.notificationsEnabled {
                if model.notifications.isEmpty {
                    Text("No Notifications")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if shouldShowNoFilterResultsMessage {
                    Text("No Filter Results")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(notificationList().reversed(), id: \.id) { notification in
                            NotificationViewItem(notification: notification)
                        }
                    }
                }
            } else {
                // swiftlint:disable:next line_length
                Text("Notifications have been disabled. Enable notifications in settings to continue receiving notifications.")
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    /// Whether to show the no filter results message.
    private var shouldShowNoFilterResultsMessage: Bool {
        return filterResults().isEmpty || (model.filter == .ERROR
                                           && model.notifications.filter { $0.severity == .error }.isEmpty)
    }

    /// Get the list of notifications to display.
    /// 
    /// - Returns: The list of notifications to display.
    private func notificationList() -> [INotification] {
        guard !preferences.preferences.notifications.doNotDisturb else {
            return model.notifications.filter { $0.severity == .error }
        }

        if model.filter == .ERROR {
            return model.notifications.filter { $0.severity == .error }
        }

        if !model.searchNotifications.isEmpty {
            return filterResults()
        }

        return model.notifications
    }

    /// Filter the results based on the search query.
    /// 
    /// - Returns: The filtered results.
    private func filterResults() -> [INotification] {
        return model.notifications.filter { notification in
            model.searchNotifications.isEmpty ||
            notification.message.localizedStandardContains(model.searchNotifications)
        }
    }
}

struct NotificationsNavigatorView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsNavigatorView()
    }
}
