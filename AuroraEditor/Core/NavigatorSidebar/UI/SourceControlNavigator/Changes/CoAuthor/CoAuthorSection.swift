//
//  CoAuthorSection.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/16.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Version_Control
import SwiftUI

struct CoAuthorSection: View {
    @Binding var addedCoAuthors: String
    @Binding var suggestions: [IAPIMentionableUser]
    @Binding var showSuggestions: Bool
    @Binding var filteredSuggestions: [IAPIMentionableUser]

    @EnvironmentObject
    var versionControl: VersionControlModel

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Divider()

            if showSuggestions &&
                versionControl.workspaceProvider == .github &&
                !versionControl.githubRepositoryMentionables.isEmpty {
                CoAuthorSuggestions(
                    suggestions: $filteredSuggestions,
                    selectedSuggestion: $addedCoAuthors,
                    showSuggestions: $showSuggestions
                )
                .padding(.horizontal, 0)
            }

            HStack {
                Text("Co-Authors")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)

                CoAuthorTextField(text: $addedCoAuthors) { newValue in
                    handleTextChange(newValue)
                }
                .frame(height: 20)
            }
            .animation(.smooth, value: showSuggestions)
        }
        .transition(.opacity)
    }

    private func handleTextChange(_ newValue: String) {
        if let lastChar = newValue.last, lastChar == " " {
            showSuggestions = false
        } else if newValue.contains("@") {
            showSuggestions = true
            filterSuggestions(for: newValue)
        } else {
            showSuggestions = false
        }
    }

    private func filterSuggestions(for query: String) {
        let components = query.split(separator: " ")

        // Extract complete co-authors (those without an ongoing input)
        let completeCoAuthorsSet = Set(components
            .filter { $0.hasPrefix("@") && $0.count > 1 }
            .map { String($0.dropFirst()).lowercased() })

        // Extract the last component for ongoing filtering
        let lastComponent = components.last.map { String($0) } ?? ""

        if lastComponent.hasPrefix("@") && lastComponent.count > 1 {
            // Ongoing co-author input
            let partialInput = String(lastComponent.dropFirst()).lowercased()
            filteredSuggestions = suggestions.filter { suggestion in
                let nameLowercased = suggestion.name?.lowercased() ?? ""
                let loginLowercased = suggestion.login.lowercased()
                let isNotAlreadyAdded = !completeCoAuthorsSet.contains(nameLowercased)
                && !completeCoAuthorsSet.contains(loginLowercased)
                let matchesPartialInput = nameLowercased.contains(partialInput)
                || loginLowercased.contains(partialInput)
                return isNotAlreadyAdded && matchesPartialInput
            }
        } else if !lastComponent.hasPrefix("@") {
            // Regular keyword filtering
            let keyword = lastComponent.lowercased()
            filteredSuggestions = suggestions.filter { suggestion in
                let nameLowercased = suggestion.name?.lowercased() ?? ""
                let loginLowercased = suggestion.login.lowercased()
                let isNotAlreadyAdded = !completeCoAuthorsSet.contains(nameLowercased)
                && !completeCoAuthorsSet.contains(loginLowercased)
                let matchesKeyword = keyword.isEmpty
                || nameLowercased.contains(keyword)
                || loginLowercased.contains(keyword)
                return isNotAlreadyAdded && matchesKeyword
            }
        } else if completeCoAuthorsSet.isEmpty {
            // No filtering needed
            filteredSuggestions = suggestions
        } else {
            // Only filter out complete co-authors
            filteredSuggestions = suggestions.filter { suggestion in
                let nameLowercased = suggestion.name?.lowercased() ?? ""
                let loginLowercased = suggestion.login.lowercased()
                return !completeCoAuthorsSet.contains(nameLowercased)
                && !completeCoAuthorsSet.contains(loginLowercased)
            }
        }
    }
}
