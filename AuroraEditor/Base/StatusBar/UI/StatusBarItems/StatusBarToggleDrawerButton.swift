//
//  StatusBarToggleDrawerButton.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 22.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A button to toggle the drawer.
internal struct StatusBarToggleDrawerButton: View {

    /// The model of the status bar.
    @ObservedObject
    private var model: StatusBarModel

    /// Initialize with model.
    internal init(model: StatusBarModel) {
        self.model = model
    }

    /// The view body.
    internal var body: some View {
        Button {
            withAnimation {
                model.isExpanded.toggle()
                if model.isExpanded && model.currentHeight < 1 {
                    model.currentHeight = 300
                }
            }
            // Show/hide terminal window
        } label: {
            Image(systemName: "rectangle.bottomthird.inset.filled")
                .imageScale(.medium)
                .accessibilityLabel(Text("Show/Hide Drawer"))
        }
        .tint(model.isExpanded ? .accentColor : .primary)
        .keyboardShortcut("Y", modifiers: [.command, .shift])
        .buttonStyle(.borderless)
        .onHover { isHovering($0) }
    }
}
