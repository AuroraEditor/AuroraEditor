//
//  SearchBar.swift
//  Aurora Editor
//
//  Created by Ziyuan Zhao on 2022/3/21.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The search bar in the navigator sidebar.
struct FindNavigatorSearchBar: View {

    /// Color scheme
    @Environment(\.colorScheme)
    var colorScheme

    /// The control active state
    @Environment(\.controlActiveState)
    private var activeState

    /// The search state
    @ObservedObject
    private var state: WorkspaceDocument.SearchState

    /// The search text
    @Binding
    private var text: String

    /// The submitted text
    @Binding
    private var submittedText: Bool

    // TODO: Can this be removed? @nanashili
    /// The control active state
    @Environment(\.controlActiveState)
    private var controlActive

    /// Initialize the search bar
    /// 
    /// - Parameter state: The search state
    /// - Parameter text: The search text
    /// - Parameter submittedText: The submitted text
    /// 
    /// - Returns: A new instance of FindNavigatorSearchBar
    init(state: WorkspaceDocument.SearchState,
         text: Binding<String>,
         submittedText: Binding<Bool>) {
        self.state = state
        self._text = text
        self._submittedText = submittedText
    }

    /// The view body.
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(nsColor: .secondaryLabelColor))
                .accessibilityLabel(Text("Search for"))
            textField
            if !text.isEmpty {
                clearSearchButton
                    .padding(.trailing, 5)
            }
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

    /// The text field
    private var textField: some View {
        TextField("Text", text: $text)
            .font(.system(size: 12))
            .disableAutocorrection(true)
            .textFieldStyle(.plain)
            .onChange(of: text) { _ in
                state.search(nil)
                submittedText = false
            }
    }

    /// We clear the text and remove the first responder which removes the cursor
    /// when the user clears the filter.
    private var clearSearchButton: some View {
        Button {
            text = ""
            state.search(nil)
            submittedText = false
            NSApp.keyWindow?.makeFirstResponder(nil)
        } label: {
            Image(systemName: "xmark.circle.fill")
                .symbolRenderingMode(.hierarchical)
                .accessibilityLabel(Text("Clear text"))
        }
        .buttonStyle(.plain)
        .opacity(activeState == .inactive ? 0.45 : 1)
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            FindNavigatorSearchBar(
                state: .init(WorkspaceDocument()),
                text: .constant(""),
                submittedText: .constant(false)
            )
        }
        .padding()
    }
}
