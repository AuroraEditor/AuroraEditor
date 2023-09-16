//
//  NotificationsNavigatorView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
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
                        ScrollViewReader { proxy in
                            ForEach(notificationList().reversed(), id: \.id) { notification in
                                NotificationViewItem(notification: notification)
                            }
                            .onChange(of: notificationList()) { _ in
                                withAnimation {
                                    proxy.scrollTo(0)
                                }
                            }
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

    private var shouldShowNoFilterResultsMessage: Bool {
        return filterResults().isEmpty || (model.filter == .ERROR
                                           && model.notifications.filter { $0.severity == .error }.isEmpty)
    }

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
