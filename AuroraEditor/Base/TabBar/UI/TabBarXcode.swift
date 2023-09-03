//
//  TabBarXcode.swift
//  Aurora Editor
//
//  Created by Lingxi Li on 4/30/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This file originates from CodeEdit, https://github.com/CodeEditApp/CodeEdit

import SwiftUI

/// This is the Xcode style background material for tab bar and breadcrumbs.
struct TabBarXcodeBackground: View {
    @Environment(\.colorScheme)
    private var colorScheme

    var body: some View {
        EffectView(
            NSVisualEffectView.Material.contentBackground,
            blendingMode: NSVisualEffectView.BlendingMode.withinWindow
        )
    }
}
