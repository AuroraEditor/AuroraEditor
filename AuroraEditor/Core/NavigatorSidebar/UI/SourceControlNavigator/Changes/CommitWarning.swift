//
//  CommitWarning.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/19.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import SwiftUI

enum CommitWarningIcon {
    case warning, information, error
}

enum WarningMessage {
    case text(String)
    case view(MarkdownTextViewRepresentable)
}

struct CommitWarning: View {

    @State
    var warningType: CommitWarningIcon

    @State
    var warningMessage: WarningMessage = .text("This is a warning message")

    var body: some View {
        HStack {
            renderWarningIcon(warningType: warningType)
            switch warningMessage {
            case .text(let message):
                Text(message)
            case .view(let view):
                view
            }
        }
    }

    private func renderWarningIcon(
        warningType: CommitWarningIcon
    ) -> some View {
        var symbol: String = ""

        switch warningType {
        case .warning:
            symbol = "exclamationmark.triangle.fill"
        case .information:
            symbol = "info.circle.fill"
        case .error:
            symbol = "exclamationmark.triangle.fill"
        }

        return Image(systemName: symbol)
            .accessibilityLabel("Commit warning label")
            .symbolRenderingMode(.multicolor)
    }
}
