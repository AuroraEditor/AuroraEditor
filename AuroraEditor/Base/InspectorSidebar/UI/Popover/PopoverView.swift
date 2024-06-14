//
//  PopoverView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/18.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Version_Control

// This popup view shows us information about
// a certain commit that is in the History Inspector
// view.
struct PopoverView: View {
    /// The commit history
    private var commit: CommitHistory

    /// Initialize with a commit history
    /// 
    /// - Parameter commit: the commit history
    /// 
    /// - Returns: a new PopoverView instance
    init(commit: CommitHistory) {
        self.commit = commit
    }

    /// The view body
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    Avatar().gitAvatar(authorEmail: commit.authorEmail)

                    VStack(alignment: .leading) {
                        Text(commit.author)
                            .fontWeight(.bold)
                        Text(commit.date.formatted(date: .long, time: .shortened))
                    }

                    Spacer()

                    Text(commit.hash)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                Text(commitDetails())
                    .frame(alignment: .leading)
            }
            .padding(.horizontal)

            Divider()
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 0) {
                // TODO: Implementation Needed
                ActionButton("Show Commit", systemImage: "clock") {}
                    .disabled(true)
                // TODO: Implementation Needed
                ActionButton("Open in Code Review", systemImage: "arrow.left.arrow.right") {}
                    .disabled(true)
                ActionButton("Email \(commit.author)", systemImage: "envelope") {
                    let service = NSSharingService(named: NSSharingService.Name.composeEmail)
                    service?.recipients = [commit.authorEmail]
                    service?.perform(withItems: [])
                }
            }
            .padding(.horizontal, 6)
        }
        .padding(.top)
        .padding(.bottom, 5)
        .frame(width: 310)
    }

    /// An action button
    private struct ActionButton: View {
        /// The title of the button
        private var title: String

        /// The system image of the button
        private var image: String

        /// The action to perform
        private var action: () -> Void

        /// The hover state 
        @State
        private var isHovering: Bool = false

        /// The enabled state
        @Environment(\.isEnabled)
        private var isEnabled

        /// Initialize with a title, system image, and action
        /// 
        /// - Parameter title: the title of the button
        /// - Parameter systemImage: the system image of the button
        /// - Parameter action: the action to perform
        /// 
        /// - Returns: a new ActionButton instance
        init(_ title: String, systemImage: String, action: @escaping () -> Void) {
            self.title = title
            self.image = systemImage
            self.action = action
        }

        /// The view body
        var body: some View {
            Button {
                action()
            } label: {
                Label(title, systemImage: image)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(isHovering && isEnabled ? .white : .primary)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .background(
                EffectView.selectionBackground(isHovering && isEnabled)
            )
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .onHover { hovering in
                isHovering = hovering
            }
        }
    }

    /// The commit details
    /// 
    /// - Returns: the commit details
    private func commitDetails() -> String {
        if commit.commiterEmail == "noreply@github.com" {
            return commit.message.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if commit.authorEmail != commit.commiterEmail {
            return commit.message.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return "\(commit.message)\n\n\(coAuthDetail())".trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// The co-author details
    /// 
    ///  - Returns: the co-author details
    private func coAuthDetail() -> String {
        if commit.commiterEmail == "noreply@github.com" {
            return ""
        } else if commit.authorEmail != commit.commiterEmail {
            return "Co-authored-by: \(commit.commiter)\n<\(commit.commiterEmail)>"
        }

        return ""
    }
}
