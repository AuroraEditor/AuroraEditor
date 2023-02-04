//
//  NotificationViewItem.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 04/02/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct NotificationViewItem: View {

    var notification: INotification

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Image(systemName: notificationIcon(severity: notification.severity))
                    .symbolRenderingMode(.multicolor)
                    .font(.system(size: 12))

                Text(notification.message)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 12))

                if notification.notificationType == .custom ||
                    notification.notificationType == .extensionSystem {
                    Image(systemName: "gear")
                        .contextMenu {
                            Button {

                            } label: {
                                Text("Don't show again")
                            }
                        }
                        .font(.system(size: 12))

                    Image(systemName: "xmark")
                        .onTapGesture {
                            Log.debug("Close notification and remove it")
                        }
                        .font(.system(size: 12))
                }
            }
        }
    }

    private func notificationIcon(severity: Severity) -> String {
        switch severity {
        case .ignore:
            return ""
        case .info:
            return "info.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .error:
            return "exclamationmark.octagon.fill"
        }
    }
}

struct NotificationViewItem_Previews: PreviewProvider {
    static var previews: some View {
        NotificationViewItem(notification: INotification(severity: .info,
                                                         message: "Test notification",
                                                         notificationType: .extensionSystem))
    }
}
