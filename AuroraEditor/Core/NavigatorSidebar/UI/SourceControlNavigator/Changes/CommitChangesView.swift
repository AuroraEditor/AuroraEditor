//
//  CommitChangesView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/11.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import OSLog
import Version_Control

/// A view for committing changes.
struct CommitChangesView: View {

    /// The git client.
    private var gitClient: GitClient?

    /// The summary text.
    @State
    var summaryText: String = ""

    /// The description text.
    @State
    var descriptionText: String = ""

    /// The workspace.
    @State
    var workspace: WorkspaceDocument

    @EnvironmentObject
    var versionControl: VersionControlModel

    /// Whether to stage all changes.
    @State
    private var stageAll: Bool = false

    // MARK: - Co-Authors

    @State
    private var addCoAuthors: Bool = false
    @State
    private var addedCoAuthors: String = ""
    @State
    private var showSuggestions: Bool = false
    @State
    private var suggestions: [IAPIMentionableUser] = []
    @State
    private var filteredSuggestions: [IAPIMentionableUser] = []
    @State
    private var height: CGFloat = 95
    @State
    private var isExpanded: Bool = false

    // MARK: - Commiting

    @State
    var repoRulesInfo: RepoRulesInfo?
    @State
    var commitToAmend: Commit?
    @State
    var coAuthorTrailers: [Trailer]? = []

    // MARK: - Repository GitHub Rule Variables

    @State
    var repoRulesEnabled: Bool = false
    @State var repoRuleCommitMessageFailures: RepoRulesMetadataFailures
    @State var repoRuleCommitAuthorFailures: RepoRulesMetadataFailures
    @State var repoRuleBranchNameFailures: RepoRulesMetadataFailures

    /// The view body.
    /// 
    /// - Parameter workspace: The workspace.
    init(workspace: WorkspaceDocument) {
        self.workspace = workspace
        self.gitClient = workspace.fileSystemClient?.model?.gitClient
        self.repoRuleCommitMessageFailures = RepoRulesMetadataFailures()
        self.repoRuleCommitAuthorFailures = RepoRulesMetadataFailures()
        self.repoRuleBranchNameFailures = RepoRulesMetadataFailures()
    }

    /// The view body.
    var body: some View {
        VStack(alignment: .leading) {
            summaryView
                .animation(.smooth(), value: height)

            VStack(alignment: .leading, spacing: 10) {
                descriptionTextField
                coAuthorToggle

                if addCoAuthors {
                    CoAuthorSection(
                        addedCoAuthors: $addedCoAuthors,
                        suggestions: $suggestions,
                        showSuggestions: $showSuggestions,
                        filteredSuggestions: $filteredSuggestions
                    )
                    .onDisappear {
                        addedCoAuthors = ""
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .frame(
                height: height,
                alignment: .topLeading
            )
            .padding(10)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.secondary, lineWidth: 0.5)
            )
            .animation(.smooth(), value: height)

            CommitButton(
                workspaceFolder: workspace.folderURL,
                summaryText: $summaryText,
                descriptionText: $descriptionText,
                branchName: $versionControl.currentWorkspaceBranch,
                addedCoAuthors: $addedCoAuthors,
                addCoAuthors: $addCoAuthors,
                repoRuleBranchNameFailures: $repoRuleBranchNameFailures
            )
        }
        .padding(10)
        .onChange(of: showSuggestions) { _ in updateHeight() }
        .onChange(of: addCoAuthors) { _ in updateHeight() }
        .animation(.easeInOut, value: isExpanded)
        .onAppear {
            suggestions = versionControl.githubRepositoryMentionables

            Task {
                await updateRepoRuleFailures(forceUpdate: true)
            }
        }
    }

    private func updateHeight() {
        if showSuggestions {
            height = addCoAuthors ? 235 : 95
        } else {
            height = addCoAuthors ? 125 : 95
        }
    }

    private var summaryView: some View {
        VStack {
            Divider()
                .padding(.leading, 5)
                .padding(.horizontal, -15)
                .padding(.bottom, 5)

            HStack(alignment: .center) {
                Avatar().gitAvatar(
                    imageSize: 30,
                    authorEmail: versionControl.workspaceEmail
                )
                .help("The workspace is configured with the following Git account: \(versionControl.workspaceEmail)")

                CommitMessageView(
                    workspace: workspace,
                    summaryText: $summaryText,
                    repoRulesEnabled: $repoRulesEnabled,
                    repoRuleCommitMessageFailures: $repoRuleCommitMessageFailures
                )
            }
        }
    }

    private var descriptionTextField: some View {
        ZStack(alignment: .topLeading) {
            if descriptionText.isEmpty {
                Text("Description")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.top, 1)
                    .padding(.leading, 4)
                    .transition(.opacity)
            }
            TextEditor(text: $descriptionText)
                .font(.system(size: 11, weight: .medium))
                .frame(height: 70)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
        }
        .frame(height: 70, alignment: .topLeading)
        .animation(.easeInOut, value: descriptionText.isEmpty)
    }

    private var coAuthorToggle: some View {
        Button {
            self.addCoAuthors.toggle()
        } label: {
            Label(
                addCoAuthors ? "Remove Co-Authors" : "Add Co-Authors",
                systemImage: "person.badge.plus"
            )
            .font(.system(size: 11))
            .foregroundColor(.secondary)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isButton)
    }
}

struct CommitChangesView_Previews: PreviewProvider {
    static var previews: some View {
        CommitChangesView(workspace: WorkspaceDocument())
    }
}
