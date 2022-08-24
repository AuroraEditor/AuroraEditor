//
//  RepositoriesView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI

struct RepositoriesView: View {
    private var gitClient: GitClient?

    @ObservedObject
    var workspace: WorkspaceDocument

    @ObservedObject
    var repositoryModel: RepositoryModel

    @State
    var repository: DummyRepo

    init?(workspace: WorkspaceDocument) {
        self.workspace = workspace
        self.repositoryModel = .init(workspace: workspace)
        guard let repoNameValue = workspace.workspaceClient?.folderURL?.lastPathComponent else {
            return nil
        }

        if let folderURL = workspace.workspaceClient?.folderURL {

            let repoNameValue: String = folderURL.lastPathComponent

            self.gitClient = GitClient.default(
                directoryURL: folderURL,
                shellClient: sharedShellClient.shellClient
            )

            let branchNames: [String] = ((try? gitClient?.getBranches(false)) ?? [])
            var branchNamesRemotes: [String] = ((try? gitClient?.getBranches(true)) ?? [])
            branchNamesRemotes = Array(Set(branchNamesRemotes).subtracting(branchNames))

            let branchesNameValue: [RepoBranch] = (branchNames.map { (branch: String) in
                 RepoBranch(name: branch)
            })

            let reduced = branchNamesRemotes.reduce(into: [String: [String]]()) { partialResult, currentTerm in
                let components = currentTerm.components(separatedBy: "/")
                guard components.count == 2 else { return }
                partialResult[components[0]] = partialResult[components[0], default: [String]()] + [components[1]]
            }

            let remotes: [RepoRemote] = (reduced.map { (key, array) in
                let content: [RepoBranch] = array.map { RepoBranch(name: $0) }
                Log.info(key, content)
                return RepoRemote(content: content, name: key)
            })

            repository = DummyRepo(
                repoName: repoNameValue,
                branches: branchesNameValue,
                remotes: remotes
            )
        } else {
            self.repository = DummyRepo(repoName: repoNameValue, branches: [
                RepoBranch(name: "master")
            ])
        }
    }

    var body: some View {
        VStack(alignment: .center) {
            if repositoryModel.isGitRepository {
                RepositoriesWrapperView(workspace: workspace, repository: repository)
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
