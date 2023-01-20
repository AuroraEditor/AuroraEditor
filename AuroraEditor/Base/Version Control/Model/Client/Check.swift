//
//  Check.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/08.
//

import Foundation

func checkIfProjectIsRepo(workspaceURL: URL) -> Bool {
    do {
        let type = try getRepositoryType(path: workspaceURL.path)

        if type == .unsafe {
            // If the path is considered unsafe by Git we won't be able to
            // verify that it's a repository (or worktree). So we'll fall back to this
            // naive approximation.
            Log.debug(type)
            return FileManager().directoryExistsAtPath("\(workspaceURL)/.git")
        }

        return type != .missing
    } catch {
        Log.error("We couldn't verify if the current project is a git repo!")
        return false
    }
}
