//
//  TabBarDivider.swift
//  Aurora Editor
//
//  Created by Lingxi Li on 4/22/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The vertical divider between tab bar items.
struct TabDivider: View {

    /// Color scheme
    @Environment(\.colorScheme)
    var colorScheme

    /// Application preferences model
    @StateObject
    private var prefs: AppPreferencesModel = .shared

    /// Divider width
    let width: CGFloat = 1

    /// The view body.
    var body: some View {
        Rectangle()
            .frame(width: width)
            .padding(.vertical, 8)
            .foregroundColor(
                Color(nsColor: colorScheme == .dark ? .white : .black)
                    .opacity(0.12)
            )
    }
}

/// The divider shadow for native tab bar style.
///
/// This is generally used in the top divider of tab bar when tab bar style is set to `native`.
struct TabBarNativeShadow: View {

    /// The shadow color
    let shadowColor = Color(nsColor: .shadowColor)

    /// The view body.
    var body: some View {
        LinearGradient(
            colors: [
                shadowColor.opacity(0.18),
                shadowColor.opacity(0.06),
                shadowColor.opacity(0.03),
                shadowColor.opacity(0.01),
                shadowColor.opacity(0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 3.8)
        .opacity(0.70)
    }
}
