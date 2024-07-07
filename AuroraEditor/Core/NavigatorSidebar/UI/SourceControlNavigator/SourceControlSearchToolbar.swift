//
//  SourceControlSearchToolbar.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/05/20.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The search toolbar for source control.
struct SourceControlSearchToolbar: View {

    /// The color scheme.
    @Environment(\.colorScheme)
    var colorScheme

    /// The active state of the control.
    @Environment(\.controlActiveState)
    private var controlActive

    /// The text.
    @State
    private var text = ""

    /// The view body.
    var body: some View {
        HStack {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .foregroundColor(.secondary)
                .accessibilityLabel(Text("Filter icon"))
            textField
            if !text.isEmpty { clearButton }
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 3)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.gray, lineWidth: 0.5)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 6
                    )
                )
        )
    }

    /// Text field.
    private var textField: some View {
        TextField("Filter", text: $text)
            .disableAutocorrection(true)
            .textFieldStyle(PlainTextFieldStyle())
    }

    /// Clear button.
    private var clearButton: some View {
        Button {
            self.text = ""
        } label: {
            Image(systemName: "xmark.circle.fill")
                .accessibilityLabel(Text("Clear button"))
        }
        .foregroundColor(.secondary)
        .buttonStyle(PlainButtonStyle())
    }
}

struct SourceControlSearchToolbar_Previews: PreviewProvider {
    static var previews: some View {
        SourceControlSearchToolbar()
    }
}
