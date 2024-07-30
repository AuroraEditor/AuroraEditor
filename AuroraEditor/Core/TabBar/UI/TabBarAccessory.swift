//
//  TabBarAccessory.swift
//  Aurora Editor
//
//  Created by Lingxi Li on 4/28/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// Accessory icon's view for tab bar.
struct TabBarAccessoryIcon: View {
    /// Unifies icon font for tab bar accessories.
    private static let iconFont = Font.system(size: 12, weight: .light, design: .default)

    /// Icon image
    private let icon: Image

    /// Action to perform when the icon is tapped
    private let action: () -> Void

    /// Initializea a new accessory icon view.
    /// 
    /// - Parameter icon: Icon image
    /// - Parameter action: Action to perform when the icon is tapped
    /// 
    /// - Returns: A new accessory icon view
    init(icon: Image, action: @escaping () -> Void) {
        self.icon = icon
        self.action = action
    }

    /// The view body.
    var body: some View {
        Button(
            action: action,
            label: {
                icon
                    .frame(height: TabBar.height - 2)
                    .padding(.horizontal, 4)
                    .contentShape(Rectangle())
            }
        )
    }
}
