//
//  RepositoriesView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI

struct RepositoriesView: View {

    @ObservedObject
    var workspace: WorkspaceDocument

    @ObservedObject
    var repositoryModel: RepositoryModel

    init?(workspace: WorkspaceDocument) {
        self.workspace = workspace
        self.repositoryModel = .init(workspace: workspace)

        if let client = workspace.workspaceClient?.model?.gitClient {
            repositoryModel.addGitRepoDetails(client: client)
        }
    }

    var body: some View {
        VStack(alignment: .center) {
            if repositoryModel.isGitRepository {
                RepositoriesWrapperView(workspace: workspace, repository: repositoryModel)
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
        .frame(maxHeight: .infinity)
    }
}

struct RepositoriesView_Previews: PreviewProvider {
    static var previews: some View {
        RepositoriesView(workspace: WorkspaceDocument().self)
    }
}
