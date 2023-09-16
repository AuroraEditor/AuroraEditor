//
//  ToolbarNotificationButtonView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct ToolbarNotificationButtonView: View {
    let notificationType: Severity
    let notificationCount: Int

    var body: some View {
        Button {
        } label: {
            HStack {
                Image(systemName: notificationType.iconName())
                    .symbolRenderingMode(.multicolor)
                    .imageScale(.small)

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
