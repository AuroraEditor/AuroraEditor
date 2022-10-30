//
//  RepositoriesView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI

struct RepositoriesView: View {

    @EnvironmentObject
    var workspace: WorkspaceDocument

    @ObservedObject
    var repositoryModel: RepositoryModel

    init?(repositoryModel: RepositoryModel) {
        self.repositoryModel = repositoryModel
    }

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
