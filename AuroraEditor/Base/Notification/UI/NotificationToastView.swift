//
//  NotificationToastView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct NotificationToastView: View {

    @ObservedObject
    private var model: NotificationsModel = .shared

    @Environment(\.colorScheme)
    var colorScheme

    @State
    public var notification: INotification

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Image(systemName: "square.dashed.inset.filled")
                    .font(.system(size: 14))
                    .cornerRadius(5)

                Text("Docker")
                    .fontWithLineHeight(fontSize: 12,
                                        lineHeight: 7)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Now")
                    .fontWithLineHeight(fontSize: 11,
                                        lineHeight: 7)
                    .foregroundColor(.secondary)

                if model.hoveringOnToast {
                    Image(systemName: "xmark")
                        .font(.system(size: 11))
                        .onTapGesture {
                            model.showNotificationToast = false
                        }
                }
            }

            Text(notification.title)
                .fontWithLineHeight(fontSize: 13,
                                    lineHeight: 8)
                .foregroundColor(.primary)
                .padding(.top, 10)

            Text(notification.message)
                .fontWeight(.regular)
                .fontWithLineHeight(fontSize: 13,
                                    lineHeight: 8)
                .foregroundColor(.secondary)
        }
        .padding(10)
        .frame(width: 350, height: 105)
        .background(colorScheme == .light ? .white : Color(hex: "#252525"))
        .cornerRadius(8)
        .shadow(radius: 1)
        .onHover { hovering in
            model.hoveringOnToast = hovering
        }
    }
}
