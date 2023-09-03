//
//  SearchBar.swift
//  Aurora Editor
//
//  Created by Ziyuan Zhao on 2022/3/21.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This file originates from CodeEdit, https://github.com/CodeEditApp/CodeEdit

import SwiftUI

struct FindNavigatorSearchBar: View {

    @Environment(\.colorScheme)
    var colorScheme

    @Environment(\.controlActiveState)
    private var activeState

    @ObservedObject
    private var state: WorkspaceDocument.SearchState

    @Binding
    private var text: String

    @Binding
    private var submittedText: Bool

    @Environment(\.controlActiveState)
    private var controlActive

    init(state: WorkspaceDocument.SearchState,
         text: Binding<String>,
         submittedText: Binding<Bool>) {
        self.state = state
        self._text = text
        self._submittedText = submittedText
    }

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(nsColor: .secondaryLabelColor))
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
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray, lineWidth: 0.5).cornerRadius(6))
    }

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
