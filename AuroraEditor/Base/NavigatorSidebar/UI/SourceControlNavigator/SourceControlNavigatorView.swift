//
//  SourceControlNavigatorView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/05/20.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct SourceControlNavigatorView: View {

    @EnvironmentObject
    private var workspace: WorkspaceDocument

    @ObservedObject
    private var preferences: AppPreferencesModel = .shared

    @State
    private var selectedSection: Int = 0

    @ObservedObject
    var repositoryModel: RepositoryModel

    init(workspace: WorkspaceDocument) {
        self.repositoryModel = .init(workspace: workspace)
    }

    var body: some View {

        if repositoryModel.isGitRepository {
            VStack {

                SegmentedControl($selectedSection,
                                 // swiftlint:disable:next line_length
                                 options: doesUserHaveGitAccounts() ? ["Changes", "Repositories", "Actions"] : ["Changes", "Repositories"],
                                 prominent: true)
                .frame(maxWidth: .infinity)
                .frame(height: 27)
                .padding(.horizontal, 8)
                .padding(.bottom, 2)
                .padding(.top, 1)
                .overlay(alignment: .bottom) {
                    Divider()
                }

                if selectedSection == 0 {
                    ChangesView(changesModel: .init(workspaceURL: workspace.workspaceURL()))
                }

                if selectedSection == 1 {
                    RepositoriesView(repositoryModel: .init(workspace: workspace))
                }

                if doesUserHaveGitAccounts() {
                    if selectedSection == 2 {
                        ActionsListView(workspace: workspace)
                    }
                }
            }
        } else {
            VStack(spacing: 14) {

                Text("This project does not seem to be a Git repository.")
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)

                Button {
                    repositoryModel.openGitCreationSheet.toggle()
                } label: {
                    Text("Create Git repository")
                        .font(.system(size: 11))
                        .foregroundColor(.blue)
                }
                .padding(.top, -5)
                .buttonStyle(.plain)
                .sheet(isPresented: $repositoryModel.openGitCreationSheet) {
                    CreateNewRepositoryView(repositoryModel: repositoryModel)
                }
            }
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .controlSize(.small)
        }
    }

    private func doesUserHaveGitAccounts() -> Bool {
        return !preferences.preferences.accounts.sourceControlAccounts.gitAccount.isEmpty
    }
}
