//
//  StatusBarBracketCountLabel.swift
//  AuroraEditor
//
//  Created by Kai Quan Tay on 10/11/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

internal struct StatusBarBracketCountLabel: View {
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
        HStack {
            if model.bracketDisplay == .seperated {
                if workspace.data.bracketCount.roundBracketCount > 0 {
                    textForString(string: "\(workspace.data.bracketCount.roundBracketCount) (")
                }
                if workspace.data.bracketCount.curlyBracketCount > 0 {
                    textForString(string: "\(workspace.data.bracketCount.curlyBracketCount) {")
                }
                if workspace.data.bracketCount.squareBracketCount > 0 {
                    textForString(string: "\(workspace.data.bracketCount.squareBracketCount) [")
                }
            } else {
                textForString(string: workspace.data.bracketCount.bracketHistory.map({ bracketType -> String in
                    switch bracketType {
                    case .round: return "("
                    case .curly: return "{"
                    case .square: return "["
                    }
                }).joined(separator: ""))
            }
        }
        .contextMenu {
            Button("Seperated") { model.bracketDisplay = .seperated }
            Button("Textual") { model.bracketDisplay = .textual }
        }
        .onHover { isHovering($0) }
    }

    private var foregroundColor: Color {
        controlActive == .inactive ? Color(nsColor: .disabledControlTextColor) : .primary
    }

    @ViewBuilder
    func textForString(string: String) -> some View {
        GroupBox {
            Text(string)
                .font(.monospaced(model.toolbarFont)())
                .foregroundColor(foregroundColor)
                .fixedSize()
                .lineLimit(1)
                .onHover { isHovering($0) }
        }
    }
}
