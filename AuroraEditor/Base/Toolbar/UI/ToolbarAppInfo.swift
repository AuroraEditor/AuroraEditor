//
//  ToolbarAppInfo.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/07/11.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

// Shows the project name, runtime instance and the build
// progress of a current project.
//
// This is still a work in progress.
public struct ToolbarAppInfo: View {

    /// The active state of the control.
    @Environment(\.controlActiveState)
    private var activeState

    /// The notification service.
    private let notificationService: NotificationService = .init()

    /// The notification model.
    @ObservedObject
    private var notificationModel: NotificationsModel = .shared

    /// Get the current time.
    /// 
    /// - Returns: The current time.
    func getTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let dateString = formatter.string(from: Date())
        return dateString
    }

    /// The view body.
    public var body: some View {
        HStack(alignment: .center) {
            HStack {
                HStack {
                    Image(systemName: "app.dashed")
                        .accessibilityLabel(Text("Developer???"))
                        .onTapGesture {
                            notificationService.notify(
                                notification: INotification(
                                    id: "121DD622-1624-4AF7-ADF7-528F81512925",
                                    severity: .info,
                                    title: "Info Notification",
                                    message: "This is a test",
                                    notificationType: .system
                                )
                            )
                        }
                        .accessibilityAddTraits(.isButton)

                    Text("AuroraEditor")
                        .font(.system(size: 11))
                        .onTapGesture {
                            notificationService.notify(
                                notification: INotification(
                                    severity: .error,
                                    title: "Info Notification",
                                    message: "This should work!",
                                    notificationType: .system
                                )
                            )
                        }
                        .accessibilityAddTraits(.isButton)

                    Image(systemName: "chevron.right")
                        .accessibilityLabel(Text("Open"))

                    Text("Chrome")
                        .font(.system(size: 11))
                }

                Spacer()

                HStack {
                    Text("Build Succeeded")
                        .font(.system(size: 11))

                    Text("|")

                    Text("Today at " + getTime())
                        .font(.system(size: 11))
                }
            }
            .padding(5)
            .background(.ultraThinMaterial)
            .cornerRadius(6)

            NotificationIndicators()
        }
        .opacity(activeState == .inactive ? 0.45 : 1)
    }
}

// Shows the notification indicators.
struct ToolbarPopoverView: View {

    /// The notification model.
    var list: [String]

    /// The workspace document.
    @EnvironmentObject
    private var workspace: WorkspaceDocument

    /// The view body.
    var body: some View {
        List(list, id: \.self) { message in
            Text(message)
        }
        .padding(.horizontal)
    }
}

struct ToolbarAppInfo_Previews: PreviewProvider {
    static var previews: some View {
        ToolbarAppInfo()
    }
}
