//
//  TabBarXcode.swift
//  Aurora Editor
//
//  Created by Lingxi Li on 4/30/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// This is the Xcode style background material for tab bar and breadcrumbs.
struct TabBarXcodeBackground: View {

    /// Color scheme
    @Environment(\.colorScheme)
    private var colorScheme

    /// The view body.
    var body: some View {
        EffectView(
            NSVisualEffectView.Material.contentBackground,
            blendingMode: NSVisualEffectView.BlendingMode.withinWindow
        )
    }
}
