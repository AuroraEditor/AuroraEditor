//
//  NotificationIndicators.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 07/02/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

///
struct NotificationIndicators: View {

    @StateObject
    private var model: NotificationsModel = .shared

    @ObservedObject
    private var preferences: AppPreferencesModel = .shared

    var body: some View {
        if preferences.preferences.notifications.notificationsEnabled {
            if !model.notifications.isEmpty {
                if !model.notifications.filter({ $0.severity == .error && $0.silent == false }).isEmpty {
                    Button {
                    } label: {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .symbolRenderingMode(.multicolor)
                                .imageScale(.small)

                            Text("\(model.notifications.filter({ $0.severity == .error && $0.silent == false }).count)")
                                .foregroundColor(.gray)
                                .font(.system(size: 10))
                        }
                    }
                    .buttonStyle(.plain)
                }

                if !preferences.preferences.notifications.doNotDisturb {
                    if !model.notifications.filter({ $0.severity == .warning && $0.silent == false }).isEmpty {
                        Button {
                        } label: {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .symbolRenderingMode(.multicolor)
                                    .imageScale(.small)

                                // swiftlint:disable:next line_length
                                Text("\(model.notifications.filter({ $0.severity == .warning && $0.silent == false }).count)")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 10))
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

struct NotificationIndicators_Previews: PreviewProvider {
    static var previews: some View {
        NotificationIndicators()
    }
}
