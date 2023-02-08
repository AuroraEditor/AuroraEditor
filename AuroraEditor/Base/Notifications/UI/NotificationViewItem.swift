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

    @State
    private var showActions: Bool = false

    var body: some View {
        VStack {
            HStack(alignment: .center) {
                if notification.icon == nil {
                    Image(systemName: notificationIcon(severity: notification.severity))
                        .symbolRenderingMode(.multicolor)
                        .font(.system(size: 14))
                } else {
                    Image(nsImage: NSImage(contentsOf: ((notification.icon ?? URL(string: ""))!))!)
                        .font(.system(size: 14))
                }

                VStack(alignment: .leading) {
                    HStack {
                        Text(notification.title)
                            .foregroundColor(.primary)
                            .font(.system(size: 11, weight: .medium))

                        Spacer()

                        if notification.notificationType == .extensionSystem {
                            Image(systemName: showActions ? "chevron.up" : "chevron.down")
                                .foregroundColor(.secondary)
                                .font(.system(size: 11))
                        }
                    }
                    .onTapGesture {
                        if notification.notificationType == .extensionSystem {
                            withAnimation {
                                showActions.toggle()
                            }
                        }
                    }

                    Text(notification.message)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 10))
                }
            }

            if showActions {
                withAnimation {
                    Button {
                    } label: {
                        Spacer()
                        Text("UPDATE")
                            .foregroundColor(.accentColor)
                            .font(.system(size: 11))
                        Spacer()
                    }
                    .shadow(radius: 0)
                    .cornerRadius(20)
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding(5)
        .contextMenu {
            Button("Copy") {
            }

            Divider()

            if notification.notificationType == .extensionSystem {
                Button("View Extension") {
                }

                Divider()
            }

            Button("Ignore Notification") {
            }

            Button("Don’t Show Again...") {
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
                                                         title: "Docker",
                                                         // swiftlint:disable:next line_length
                                                         message: "A new update of the docker extension for Aurora Editor is now available.",
                                                         notificationType: .extensionSystem))
    }
}
