//
//  CommitMessageView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/19.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import SwiftUI

struct CommitMessageView: View {

    @State var workspace: WorkspaceDocument

    @Binding var summaryText: String

    // MARK: - Repository GitHub Rule Variables

    @Binding var repoRulesEnabled: Bool
    @Binding var repoRuleCommitMessageFailures: RepoRulesMetadataFailures
    @State private var isRuleFailurePopoverOpen: Bool = false

    public var body: some View {
        HStack(spacing: 0) {
            TextField(text: $summaryText) {
                Text(checkIfChangeIsOne() ? getFirstFileSummary() : "Summary (Required)")
                    .font(.system(size: 11, weight: .medium))
            }
            .font(.system(size: 11, weight: .medium))
            .padding(.vertical, 6)
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .textFieldStyle(.plain)

            if summaryText.count > 50 {
                Image(systemName: "info.circle")
                    .padding(.trailing, 10)
                    .help("Ideal commit summaries are concise (under 50 chars) and descriptive")
                    .accessibilityLabel("Character count warning")
                    .accessibilityHint("Tap for information about ideal commit summary length")
                    .accessibilityAddTraits(.isButton)
                    .transition(.scale.combined(with: .opacity))
            }

            if showRepoRuleCommitMessageFailureHint() {
                renderRepoRuleCommitMessageFailureHint()
            }
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.secondary, lineWidth: 0.5)
        )
        .disabled(getFirstFileSummary() == "Unable to commit")
    }

    // MARK: - Repository GitHub Rule Functions

    @ViewBuilder
    private func renderRepoRuleCommitMessageFailureHint() -> some View {
        if repoRuleCommitMessageFailures.status == .pass {
            EmptyView()
        }

        let canBypass = repoRuleCommitMessageFailures.status == .bypass

        Image(systemName: canBypass ? "info.circle" : "exclamationmark.octagon.fill")
            .padding(.trailing, 10)
            .help(repoRuleCommitMessageFailureHint(canBypass: canBypass))
            .accessibilityLabel("Commit message rule failure")
            .accessibilityHint("Tap for information about commit message rule failure")
            .accessibilityAddTraits(.isButton)
            .transition(.scale.combined(with: .opacity))
            .onTapGesture {
                isRuleFailurePopoverOpen.toggle()
            }
            .popover(
                isPresented: $isRuleFailurePopoverOpen,
                arrowEdge: .trailing
            ) {
                VStack {
                    Text("Commit Message Rule Failures")
                        .font(
                            .system(
                                size: 14,
                                weight: .semibold
                            )
                        )
                    RepoRulesMetadataFailureList(
                        failures: repoRuleCommitMessageFailures,
                        leadingText: "This commit message"
                    )
                }
                .padding()
            }
    }

    private func repoRuleCommitMessageFailureHint(canBypass: Bool) -> String {
"\(canBypass ? "Warning" : "Error"): Commit message fails repository rules\(canBypass ? ", but you can bypass them" : ""). View details." // swiftlint:disable:this line_length
    }

    private func showRepoRuleCommitMessageFailureHint() -> Bool {
        repoRulesEnabled && repoRuleCommitMessageFailures.status != .pass
    }

    // MARK: - Placeholder Functions

    /// Checks if the change is one.
    ///
    /// If there is only one changed file in list we will return true else
    /// if there is more than one we return false.
    ///
    /// - Returns: Whether the change is one.
    private func checkIfChangeIsOne() -> Bool {
        return workspace.fileSystemClient?.model?.changed.count == 1
    }

    /// Gets the first file summary.
    ///
    /// Based on the Git Change type of the file we create a summary string
    /// that matches that of the Git Change type
    ///
    /// - Returns: The summary string.
    private func getFirstFileSummary() -> String {
        let fileName = workspace.fileSystemClient?.model?.changed[0].fileName
        switch workspace.fileSystemClient?.model?.changed[0].gitStatus {
        case .modified:
            return "Update \(fileName ?? "Unknown File")"
        case .added:
            return "Created \(fileName ?? "Unknown File")"
        case .copied:
            return "Copied \(fileName ?? "Unknown File")"
        case .deleted:
            return "Deleted \(fileName ?? "Unknown File")"
        case .fileTypeChange:
            return "Changed file type \(fileName ?? "Unknown File")"
        case .renamed:
            return "Renamed \(fileName ?? "Unknown File")"
        case .unknown:
            return "Summary (Required)"
        case .updatedUnmerged:
            return "Unmerged file \(fileName ?? "Unknown File")"
        case .ignored:
            return "Ignore file \(fileName ?? "Unknown File")"
        case .unchanged:
            return "Unchanged"
        case .none:
            return "Unable to commit"
        }
    }
}
