//
//  NotificationIcon.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/10/21.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// Notification icon
struct NotificationIcon: View {

    /// Notification
    @State
    public var notification: INotification

    //// The view body.
    var body: some View {
        switch notification.notificationType {
        case .system:
            Image(systemName: notification.severity.iconName())
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: 14))
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .accessibilityLabel(Text("System Notification"))
        case .update:
            Image(systemName: "square.and.arrow.down.fill")
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: 14))
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .accessibilityLabel(Text("Update Notification"))
        case .extensionSystem:
            AsyncImage(url: notification.icon)
                .font(.system(size: 14))
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .accessibilityLabel(Text("Extension Notification"))
        case .custom:
            AsyncImage(url: notification.icon)
                .font(.system(size: 14))
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .accessibilityLabel(Text("Custom Notification"))
        }
    }
}
