//
//  RepositoriesView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/05/20.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The view for repositories.
struct RepositoriesView: View {

    /// The workspace document.
    @EnvironmentObject
    var workspace: WorkspaceDocument

    /// The repository model.
    @ObservedObject
    var repositoryModel: RepositoryModel

    /// Initializes the view.
    /// 
    /// - Parameter repositoryModel: The repository model.
    init?(repositoryModel: RepositoryModel) {
        self.repositoryModel = repositoryModel
    }

    /// The view body.
    var body: some View {
        VStack(alignment: .center) {
            if repositoryModel.isGitRepository {
                RepositoriesWrapperView(repository: repositoryModel)
            } else {
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
        }
        .onAppear {
            if let client = workspace.fileSystemClient?.model?.gitClient {
                repositoryModel.addGitRepoDetails(client: client)
            }
        }
        .frame(maxHeight: .infinity)
    }
}

struct RepositoriesView_Previews: PreviewProvider {
    static var previews: some View {
        RepositoriesView(repositoryModel: .init(workspace: .init()))
    }
}
