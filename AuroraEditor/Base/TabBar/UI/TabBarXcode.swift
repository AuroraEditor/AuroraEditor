//
//  TabBarXcode.swift
//  AuroraEditor
//
//  Created by Lingxi Li on 4/30/22.
//

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
