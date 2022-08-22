//
//  ToolbarPlusMenu.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 21/8/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

public struct ToolbarPlusMenu: View {

    @State var workspace: WorkspaceDocument?

    @Environment(\.controlActiveState)
    private var controlActive

    @State
    private var displayPopover: Bool = false

    public var body: some View {
        Button {
            workspace?.openTab(item: WebTab(url: URL(string: "https://auroraeditor.com")))
        } label: {
            Image(systemName: "globe")
                .scaledToFill()
        }
        .buttonStyle(.plain)
    }
}
