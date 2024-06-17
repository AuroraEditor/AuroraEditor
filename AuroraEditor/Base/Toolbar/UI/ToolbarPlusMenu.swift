//
//  ToolbarPlusMenu.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 21/8/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The plus menu in the toolbar.
public struct ToolbarPlusMenu: View {

    /// Workspace document.
    @State
    var workspace: WorkspaceDocument?

    /// Control active state.
    @Environment(\.controlActiveState)
    private var controlActive

    /// Display popover state.
    @State
    private var displayPopover: Bool = false

    /// The view body.
    public var body: some View {
        Button {
            workspace?.openTab(item: WebTab(url: URL(string: "https://auroraeditor.com")))
        } label: {
            Image(systemName: "globe")
                .scaledToFill()
                .accessibilityLabel(Text("Open web tab"))
        }
        .buttonStyle(.plain)
    }
}
