//
//  Rev-Parse.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/16.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

enum RepositoryType {
    case bare
    case regular
    case missing
    case unsafe
}

/// Attempts to fulfill the work of isGitRepository and isBareRepository while
/// requiring only one Git process to be spawned.
///
/// Returns 'bare', 'regular', or 'missing' if the repository couldn't be
/// found.
func getRepositoryType(path: String) throws -> RepositoryType {
    if FileManager().directoryExistsAtPath(path) {
        return .missing
    }

    do {
        let result = try ShellClient.live().run(
            "cd \(path);git rev-parse --is-bare-repository -show-cdup"
        )

        if !result.contains(GitError.notAGitRepository.rawValue) {
            let isBare = result.split(separator: "\n", maxSplits: 2)

            return isBare.description == "true" ? .bare : .regular
        }

        if result.contains("fatal: detected dubious ownership in repository at") {
            return .unsafe
        }

        return .missing
    } catch {
        // This could theoretically mean that the Git executable didn't exist but
        // in reality it's almost always going to be that the process couldn't be
        // launched inside of `path` meaning it didn't exist. This would constitute
        // a race condition given that we stat the path before executing Git.
        Log.error("Git doesn't exist, returning as missing")
        return .missing
    }
}
