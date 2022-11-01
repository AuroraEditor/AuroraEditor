//
//  SourceControlNavigatorView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI

struct SourceControlNavigatorView: View {

    @EnvironmentObject
    private var workspace: WorkspaceDocument

    @ObservedObject
    private var preferences: AppPreferencesModel = .shared

    @State
    private var selectedSection: Int = 0

    var body: some View {
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
    }

    private func doesUserHaveGitAccounts() -> Bool {
        return !preferences.preferences.accounts.sourceControlAccounts.gitAccount.isEmpty
    }
}
