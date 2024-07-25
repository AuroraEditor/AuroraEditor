//
//  CoAuthorSuggestions.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/15.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import SwiftUI
import Version_Control

struct CoAuthorSuggestions: View {
    @Binding var suggestions: [IAPIMentionableUser]
    @Binding var selectedSuggestion: String
    @Binding var showSuggestions: Bool

    var body: some View {
        List {
            ForEach(suggestions, id: \.login) { suggestion in
                HStack {
                    Avatar().contributorAvatar(
                        imageSize: 16,
                        contributorAvatarURL: suggestion.avatar_url
                    )

                    SanitizedMentionable(suggestion: suggestion)
                }
                .accessibilityAddTraits(.isButton)
                .onTapGesture {
                    replacePartialInputWithSuggestion(suggestion.login)
                    showSuggestions = false
                }
            }
        }
        .listStyle(.plain)
        .padding(.horizontal, 0)
        .frame(minHeight: 30, maxHeight: 110)
    }

    private func replacePartialInputWithSuggestion(_ suggestionLogin: String) {
        let components = selectedSuggestion.split(
            separator: " ",
            omittingEmptySubsequences: false
        )

        if let lastComponent = components.last, lastComponent.hasPrefix("@") {
            // Replace the partial input with the full suggestion
            selectedSuggestion = components.dropLast().joined(separator: " ")
        }

        if !selectedSuggestion.isEmpty && !selectedSuggestion.hasSuffix(" ") {
            selectedSuggestion += " "
        }

        selectedSuggestion += "@" + suggestionLogin + " "
    }
}
