//
//  StatusBarCursorLocationLabel.swift
//  AuroraEditorModules/StatusBar
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI

internal struct StatusBarCursorLocationLabel: View {
    @Environment(\.controlActiveState)
    private var controlActive

    @ObservedObject
    private var model: StatusBarModel

    @ObservedObject
    private var shared: SharedObjects = .shared

    internal init(model: StatusBarModel) {
        self.model = model
    }

    internal var body: some View {
        Text("Line: \(shared.caretPos.line)  Col: \(shared.caretPos.column)")
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
