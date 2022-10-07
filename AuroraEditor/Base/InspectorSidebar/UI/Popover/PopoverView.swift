//
//  PopoverView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/04/18.
//

import SwiftUI
import Version_Control

// This popup view shows us information about
// a certain commit that is in the History Inspector
// view.
struct PopoverView: View {

    private var commit: CommitHistory

    init(commit: CommitHistory) {
        self.commit = commit
    }

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

    private struct ActionButton: View {

        private var title: String
        private var image: String
        private var action: () -> Void

        @State
        private var isHovering: Bool = false

        @Environment(\.isEnabled) private var isEnabled

        init(_ title: String, systemImage: String, action: @escaping () -> Void) {
            self.title = title
            self.image = systemImage
            self.action = action
        }

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

    private func commitDetails() -> String {
        if commit.commiterEmail == "noreply@github.com" {
            return commit.message.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if commit.authorEmail != commit.commiterEmail {
            return commit.message.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            return "\(commit.message)\n\n\(coAuthDetail())".trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    private func coAuthDetail() -> String {
        if commit.commiterEmail == "noreply@github.com" {
            return ""
        } else if commit.authorEmail != commit.commiterEmail {
            return "Co-authored-by: \(commit.commiter)\n<\(commit.commiterEmail)>"
        }
        return ""
    }
}
