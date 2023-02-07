//
//  NotificationProfileToggle.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 07/02/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct NotificationProfileToggle: View {

    @State
    public var title: String

    @State
    public var enabledOptions: [String] = []

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .foregroundColor(.primary)
                .font(.custom("SF Pro Text",
                              size: 13))
                .fontWeight(.medium)

            if !enabledOptions.isEmpty {
                Text("Sounds, Banners")
                    .foregroundColor(.secondary)
                    .font(.custom("SF Pro Text",
                                  size: 11))
            }
        }
    }
}

struct NotificationProfileToggle_Previews: PreviewProvider {
    static var previews: some View {
        NotificationProfileToggle(title: "Account")
    }
}
