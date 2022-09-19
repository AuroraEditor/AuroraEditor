//
//  Branch.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/12.
//  Copyright © 2022 Aurora Company. All rights reserved.
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

public struct Branches {
    func getCurrentBranch(directoryURL: URL) throws -> String {
        return try ShellClient.live().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git rev-parse --abbrev-ref HEAD"
        ).removingNewLines()
    }

    func getBranches(_ allBranches: Bool = false, directoryURL: URL) throws -> [String] {
        if allBranches == true {
            return try ShellClient.live().run(
                "cd \(directoryURL.relativePath.escapedWhiteSpaces());git branch -a --format \"%(refname:short)\""
            )
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }
        }
        return try ShellClient.live().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git branch --format \"%(refname:short)\""
        )
        .components(separatedBy: "\n")
        .filter { !$0.isEmpty }
    }

    /// Create a new branch from the given start point.
    ///
    /// @param name - The name of the new branch
    ///
    /// @param startPoint - A committish string that the new branch should be based
    /// on, or undefined if the branch should be created based
    /// off of the current state of HEAD
    func createBranch(directoryURL: URL,
                      name: String,
                      startPoint: String?,
                      noTrack: Bool?) throws {
        var args: [String] = startPoint != nil ? ["branch", name, startPoint!] : ["branch", name]

        if noTrack != nil {
            args.append("--no-track")
        }

        try ShellClient().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git \(args.joined(separator: " "))")
    }

    /// Rename the given branch to a new name.
    func renameBranch(directoryURL: URL,
                      branch: String,
                      newName: String) throws {
        try ShellClient().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git branch -m \(branch) \(newName)")
    }

    /// Delete the branch locally.
    func deleteLocalBranch(directoryURL: URL,
                           branchName: String) throws -> Bool {
        try ShellClient().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git branch -D \(branchName)")
        return true
    }
    /// Deletes a remote branch
    ///
    /// @param remoteName - the name of the remote to delete the branch from
    /// @param remoteBranchName - the name of the branch on the remote
    func deleteRemoteBranch(directoryURL: URL,
                            remoteName: String,
                            remoteBranchName: String) throws {
        let args: [Any] = [
            "push",
            remoteName,
            ":\(remoteBranchName)"
        ]

        let result = try ShellClient.live().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git \(args)")

        // It's possible that the delete failed because the ref has already
        // been deleted on the remote. If we identify that specific
        // error we can safely remove our remote ref which is what would
        // happen if the push didn't fail.
        if result == GitError.branchDeletionFailed.rawValue {
            let ref = "refs/remotes/\(remoteName)/\(remoteBranchName)"
            try deleteRef(directoryURL: directoryURL, ref: ref, reason: nil)
        }
    }

    /// Finds branches that have a tip equal to the given committish
    ///
    /// @param commitish - a sha, HEAD, etc that the branch(es) tip should be
    /// @returns - list branch names. null if an error is encountered
    func getBranchesPointedAt(directoryURL: URL,
                              commitsh: String) throws -> [String]? {
        let args = [
            "branch",
            "--points-at=\(commitsh)",
            "--format=%(refname:short)"
        ]

        let result = try ShellClient.live().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git \(args)")
        let resultSplit = result.split(separator: "\n").map { String($0) }
        let resultRange = Array(resultSplit[-1...0])

        return resultRange
    }

    func getMergedBranches() {}
}
