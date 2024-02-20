//
//  ToolbarNotificationButtonView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The `ToolbarNotificationButtonView` SwiftUI view displays a button in the toolbar with a notification icon
/// and a count for the specified notification type.
struct ToolbarNotificationButtonView: View {
    /// The severity level of the notifications to represent.
    let notificationType: Severity

    /// The count of notifications for the specified type.
    let notificationCount: Int

    var body: some View {
        Button {
            NotificationCenter.default.post(
                name: .changeNavigatorPane,
                object: 5
            )
        } label: {
            HStack {
                // Display the notification icon based on severity.
                Image(systemName: notificationType.iconName())
                    .symbolRenderingMode(.multicolor)
                    .imageScale(.small)

                // Display the notification count.
                Text("\(notificationCount)")
                    .foregroundColor(.gray)
                    .font(.system(size: 10))
            }
        }
        .buttonStyle(.plain)
    }
}

struct ToolbarNotificationButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ToolbarNotificationButtonView(notificationType: .error,
                                      notificationCount: 10)
    }
}
