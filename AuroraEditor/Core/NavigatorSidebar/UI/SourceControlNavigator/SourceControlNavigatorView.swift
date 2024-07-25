//
//  SourceControlNavigatorView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/05/20.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import GRDB

/// A view for source control navigator.
struct SourceControlNavigatorView: View {

    /// The workspace document.
    @EnvironmentObject
    private var workspace: WorkspaceDocument

    /// Application preferences model
    @ObservedObject
    private var preferences: AppPreferencesModel = .shared

    /// The selected section.
    @State
    private var selectedSection: Int = 0

    /// The repository model.
    @ObservedObject
    var repositoryModel: RepositoryModel

    @EnvironmentObject
    private var versionControl: VersionControlModel

    /// Initializes the view.
    /// 
    /// - Parameter workspace: The workspace document.
    init(workspace: WorkspaceDocument) {
        self.repositoryModel = .init(workspace: workspace)
    }

    /// The view body.
    var body: some View {
        if versionControl.workspaceIsRepository {
            VStack {
                SegmentedControl($selectedSection,
                                 options: doesUserHaveGitAccounts()
                                    ? ["Changes", "Repositories", "Actions"]
                                    : ["Changes", "Repositories"],
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
                    ChangesView()
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

    /// Checks if the user has git accounts stored in the preferences database.
    /// - Returns: A boolean value indicating whether the user has git accounts.
    /// - Throws: An error if there is an issue accessing the database or executing the query.
    func doesUserHaveGitAccounts() -> Bool {
        do {
            let dbQueue = try DatabaseQueue.fetchDatabase()
            return try dbQueue.read { database -> Bool in
                let count = try Int.fetchOne(database, sql: """
                    SELECT COUNT(*) FROM \(AccountPreferences.databaseTableName)
                    """) ?? 0
                return count > 0 // swiftlint:disable:this empty_count
            }
        } catch {
            return false
        }
    }
}
