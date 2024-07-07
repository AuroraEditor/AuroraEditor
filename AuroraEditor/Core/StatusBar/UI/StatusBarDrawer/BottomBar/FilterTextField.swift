//
//  FilterTextField.swift
//  Aurora Editor
//
//  Created by Stef Kors on 12/04/2022.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A text field with a filter icon and a clear button.
struct FilterTextField: View {

    /// The title of the text field.
    let title: String

    /// The text in the text field.
    @Binding
    var text: String

    /// The view body.
    var body: some View {
        HStack {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .foregroundColor(Color(nsColor: .secondaryLabelColor))
                .accessibilityLabel(Text("Filter icon"))
            textField
            if !text.isEmpty { clearButton }
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 3)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.gray, lineWidth: 0.5)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 4
                    )
                )
        )
    }

    /// The text field.
    private var textField: some View {
        TextField(title, text: $text)
            .disableAutocorrection(true)
            .textFieldStyle(PlainTextFieldStyle())
    }

    /// The clear button.
    private var clearButton: some View {
        Button {
            self.text = ""
        } label: {
            Image(systemName: "xmark.circle.fill")
                .accessibilityLabel(Text("Clear"))
        }
        .foregroundColor(.secondary)
        .buttonStyle(PlainButtonStyle())
    }
}

struct FilterTextField_Previews: PreviewProvider {
    static var previews: some View {
        FilterTextField(title: "Filter", text: .constant(""))
        FilterTextField(title: "Filter", text: .constant("codeedi"))
    }
}
