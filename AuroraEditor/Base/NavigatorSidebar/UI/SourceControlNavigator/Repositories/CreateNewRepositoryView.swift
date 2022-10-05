//
//  CreateNewRepositoryView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/16.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI
import Version_Control

// TODO: Still need to add support for repo name, description and readme
struct CreateNewRepositoryView: View {

    @ObservedObject
    var repositoryModel: RepositoryModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Create a New Repository")

            Divider()

            Group {
                Text("Name")
                    .font(.system(size: 11))
                    .padding(.top, 5)
                    .padding(.bottom, -5)
                TextField("Name", text: $repositoryModel.repositoryName)
                    .textFieldStyle(.roundedBorder)
                Text("Great repository names are short and memorable.")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            Group {
                Text("Description (Optional)")
                    .font(.system(size: 11))
                    .padding(.top, 5)
                    .padding(.bottom, -5)
                TextField("Description", text: $repositoryModel.repositoryDescription)
                    .textFieldStyle(.roundedBorder)
            }
            Group {
                Text("Local Path")
                    .font(.system(size: 11))
                    .padding(.top, 5)
                    .padding(.bottom, -5)
                TextField("Local Path", text: $repositoryModel.repositoryLocalPath)
                    .textFieldStyle(.roundedBorder)
                    .disabled(true)
            }
            Toggle(isOn: $repositoryModel.addReadme) {
                Text("Initialize this project with a README")
                    .font(.system(size: 11))
            }
            .padding(.top, 5)

            HStack {
                Spacer()
                Button {
                    repositoryModel.openGitCreationSheet.toggle()
                } label: {
                    Text("Cancel")
                        .font(.system(size: 12))
                        .foregroundColor(.primary)
                        .padding()
                }

                Button {
                    do {
                        guard let projectPath = repositoryModel.workspace.fileSystemClient?.folderURL else {
                            return
                        }
                        try initGitRepository(directoryURL: projectPath)

                        repositoryModel.isGitRepository = checkIfProjectIsRepo(workspaceURL: projectPath)
                        repositoryModel.openGitCreationSheet.toggle()
                    } catch {
                        Log.error("Unable to create a repo for project")
                    }
                } label: {
                    Text("Create Repository")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top)
        }
        .padding()
        .frame(width: 500)
    }
}

struct CreateNewRepositoryView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewRepositoryView(repositoryModel: RepositoryModel(workspace: WorkspaceDocument()))
    }
}
