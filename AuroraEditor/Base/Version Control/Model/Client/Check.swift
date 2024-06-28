//
//  Check.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/08.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Check if the current project is a git repository
/// 
/// - Parameter workspaceURL: Workspace URL
/// 
/// - Returns: a boolean value
func checkIfProjectIsRepo(workspaceURL: URL) -> Bool {
    do {
        let type = try getRepositoryType(path: workspaceURL.path)

        if type == .unsafe {
            // If the path is considered unsafe by Git we won't be able to
            // verify that it's a repository (or worktree). So we'll fall back to this
            // naive approximation.
            self.loggerdebug(type)
            return FileManager().directoryExistsAtPath("\(workspaceURL)/.git")
        }

        return type != .missing
    } catch {
        self.loggererror("We couldn't verify if the current project is a git repo!")
        return false
    }
}
