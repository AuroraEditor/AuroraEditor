//
//  NotificationToastView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The `NotificationToastView` SwiftUI view displays a notification toast with title and message.
struct NotificationToastView: View {
    // Observed object for managing notifications.
    @ObservedObject private var model: NotificationsModel = .shared

    // Environment value for color scheme.
    @Environment(\.colorScheme) var colorScheme

    // The notification to display.
    @State public var notification: INotification

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                // Notification icon.
                Image(systemName: "square.dashed.inset.filled")
                    .font(.system(size: 14))
                    .cornerRadius(5)

                // Notification source or identifier.
                Text("Docker")
                    .fontWithLineHeight(fontSize: 12, lineHeight: 7)
                    .foregroundColor(.secondary)
                Spacer()

                // Timestamp for when the notification was received.
                Text("Now")
                    .fontWithLineHeight(fontSize: 11, lineHeight: 7)
                    .foregroundColor(.secondary)

                // Close button for dismissing the notification.
                if model.hoveringOnToast {
                    Image(systemName: "xmark")
                        .font(.system(size: 11))
                        .onTapGesture {
                            model.showNotificationToast = false
                        }
                }
            }

            // Title of the notification.
            Text(notification.title)
                .fontWithLineHeight(fontSize: 13, lineHeight: 8)
                .foregroundColor(.primary)
                .padding(.top, 10)

            // Message content of the notification.
            Text(notification.message)
                .fontWeight(.regular)
                .fontWithLineHeight(fontSize: 13, lineHeight: 8)
                .foregroundColor(.secondary)
        }
        .padding(10)
        .frame(width: 350, height: 105)
        .background(colorScheme == .light ? .white : Color(hex: "#252525"))
        .cornerRadius(8)
        .shadow(radius: 1)
        .onHover { hovering in
            // Track if the mouse is hovering over the notification for interaction.
            model.hoveringOnToast = hovering
        }
    }
}
