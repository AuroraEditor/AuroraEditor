//
//  StatusBarCursorLocationLabel.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 22.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

internal struct StatusBarCursorLocationLabel: View {
    @Environment(\.controlActiveState)
    private var controlActive

    @ObservedObject
    private var model: StatusBarModel

    @EnvironmentObject
    private var workspace: WorkspaceDocument

    internal init(model: StatusBarModel) {
        self.model = model
    }

    internal var body: some View {
        Text("Line: \(workspace.data.caretPos.line)  Col: \(workspace.data.caretPos.column)")
            .font(model.toolbarFont)
            .foregroundColor(foregroundColor)
            .fixedSize()
            .lineLimit(1)
            .onHover { isHovering($0) }
    }

    private var foregroundColor: Color {
        controlActive == .inactive ? Color(nsColor: .disabledControlTextColor) : .primary
    }
}
