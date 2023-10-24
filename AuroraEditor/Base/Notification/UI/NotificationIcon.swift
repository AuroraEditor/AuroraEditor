//
//  NotificationIcon.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/10/21.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct NotificationIcon: View {

    @State public var notification: INotification

    var body: some View {
        switch notification.notificationType {
        case .system:
            Image(systemName: notification.severity.iconName())
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: 14))
                .cornerRadius(5)
        case .update:
            Image(systemName: "square.and.arrow.down.fill")
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: 14))
                .cornerRadius(5)
        case .extensionSystem:
            AsyncImage(url: notification.icon)
                .font(.system(size: 14))
                .cornerRadius(5)
        case .custom:
            AsyncImage(url: notification.icon)
                .font(.system(size: 14))
                .cornerRadius(5)
        }
    }
}
