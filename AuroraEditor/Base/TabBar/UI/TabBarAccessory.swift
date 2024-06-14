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

/// Tab bar accessory area background for native tab bar style.
struct TabBarAccessoryNativeBackground: View {
    /// Divider position
    enum DividerPosition {
        /// No divider
        case none

        /// Divider at leading
        case leading

        /// Divider at trailing
        case trailing
    }

    /// Divider alignment
    private let dividerPosition: Self.DividerPosition

    /// Initialize a new accessory background view.
    /// 
    /// - Parameter dividerAt: Divider position
    /// 
    /// - Returns: A new accessory background view
    init(dividerAt: Self.DividerPosition) {
        self.dividerPosition = dividerAt
    }

    /// Get the alignment of the divider.
    /// 
    /// - Returns: The alignment of the divider
    private func getAlignment() -> Alignment {
        switch self.dividerPosition {
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        default:
            return .leading
        }
    }

    /// Get the padding direction of the divider.
    /// 
    /// - Returns: The padding direction of the divider
    private func getPaddingDirection() -> Edge.Set {
        switch self.dividerPosition {
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        default:
            return .leading
        }
    }

    /// The view body.
    var body: some View {
        ZStack(alignment: getAlignment()) {
            TabBarNativeInactiveBackgroundColor()
                .padding(getPaddingDirection(), dividerPosition == .none ? 0 : 1)
            TabDivider()
                .opacity(dividerPosition == .none ? 0 : 1)
            TabBarTopDivider()
                .frame(maxHeight: .infinity, alignment: .top)
        }
    }
}
