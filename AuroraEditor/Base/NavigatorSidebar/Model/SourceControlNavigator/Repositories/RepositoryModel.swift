//
//  RepositoryModel.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/16.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

public final class RepositoryModel: ObservableObject {

    let workspace: WorkspaceDocument

    @Published
    var openGitCreationSheet: Bool = false

    @Published
    var repositoryName: String = ""

    @Published
    var repositoryDescription: String = ""

    @Published
    var repositoryLocalPath: String = ""

    @Published
    var addReadme: Bool = false

    @Published
    var isGitRepository: Bool = false

    init(workspace: WorkspaceDocument) {
        self.workspace = workspace
        guard let projectPath = workspace.workspaceClient?.folderURL else { return }
        self.repositoryLocalPath = projectPath.path
        self.repositoryName = projectPath.lastPathComponent
        self.isGitRepository = checkIfProjectIsRepo()
    }

    func checkIfProjectIsRepo() -> Bool {
        guard let path = workspace.workspaceClient?.folderURL else {
            return false
        }

        do {
            let type = try getRepositoryType(path: path.path)

            if type == .unsafe {
                // If the path is considered unsafe by Git we won't be able to
                // verify that it's a repository (or worktree). So we'll fall back to this
                // naive approximation.
                Log.debug(type)
                return FileManager().directoryExistsAtPath("\(path)/.git")
            }

            return type != .missing
        } catch {
            Log.error("We couldn't verify if the current project is a git repo!")
            return false
        }
    }
}
