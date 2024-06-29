//
//  StatusBarBracketCountLabel.swift
//  Aurora Editor
//
//  Created by Kai Quan Tay on 10/11/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A label that displays the bracket count.
internal struct StatusBarBracketCountLabel: View {

    /// The active state of the control.
    @Environment(\.controlActiveState)
    private var controlActive

    /// The model of the status bar.
    @ObservedObject
    private var model: StatusBarModel

    /// The workspace document.
    @EnvironmentObject
    private var workspace: WorkspaceDocument

    /// Initialize with model.
    /// 
    /// - Parameter model: The statusbar model.
    internal init(model: StatusBarModel) {
        self.model = model
    }

    /// The view body.
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

    /// The foreground color of the text.
    private var foregroundColor: Color {
        controlActive == .inactive ? Color(nsColor: .disabledControlTextColor) : .primary
    }

    /// The view builder for the text.
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
