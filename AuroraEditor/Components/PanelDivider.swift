//
//  PanelDivider.swift
//  Aurora Editor
//
//  Created by Austin Condiff on 5/10/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A view that represents a panel divider.
public struct PanelDivider: View {
    /// The color scheme.
    @Environment(\.colorScheme)
    private var colorScheme

    /// Creates a new instance of `PanelDivider`.
    public init() {}

    /// The view body.
    public var body: some View {
        Divider()
            .opacity(0)
            .overlay(
                Color(.black)
                    .opacity(colorScheme == .dark ? 0.65 : 0.13)
            )
    }
}
