//
//  NotificationProfileToggle.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A view that represents a notification profile toggle.
struct NotificationProfileToggle: View {
    /// The title of the toggle.
    @State
    public var title: String

    /// The enabled options.
    @State
    public var enabledOptions: [String] = []

    /// The view body
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
