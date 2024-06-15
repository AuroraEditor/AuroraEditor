//
//  Branch.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/12.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

/// Branches
public struct Branches {
    /// Branch Name
    /// 
    /// - Parameter directoryURL: Directory URL
    /// 
    /// - Returns: Branch Name
    /// 
    /// - Throws: Error
    func getCurrentBranch(directoryURL: URL) throws -> String {
        return try ShellClient.live().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git rev-parse --abbrev-ref HEAD"
        ).removingNewLines()
    }

    /// Get all branches
    /// 
    /// - Parameter allBranches: All Branches
    /// - Parameter directoryURL: Directory URL
    /// 
    /// - Returns: Branches
    /// 
    /// - Throws: Error
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
    /// - Parameter directoryURL: The directory to create the branch in
    /// - Paramter name: The name of the new branch
    /// - Paramter startPoint: A committish string that the new branch should be based
    /// on, or undefined if the branch should be created based off of the current state of HEAD
    /// - Paramter noTrack: If true, the new branch will not be set to track a remote branch
    /// 
    /// - Throws: Error
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
    /// 
    /// - Parameter directoryURL: The directory to rename the branch in
    /// - Parameter branch: The name of the branch to rename
    /// - Parameter newName: The new name for the branch
    /// 
    /// - Throws: Error
    func renameBranch(directoryURL: URL,
                      branch: String,
                      newName: String) throws {
        try ShellClient().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git branch -m \(branch) \(newName)")
    }

    /// Delete the branch locally.
    /// 
    /// - Parameter directoryURL: The directory to delete the branch in
    /// - Parameter branchName: The name of the branch to delete
    /// 
    /// - Returns: Bool
    /// 
    /// - Throws: Error
    func deleteLocalBranch(directoryURL: URL,
                           branchName: String) throws -> Bool {
        try ShellClient().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git branch -D \(branchName)")
        return true
    }
    /// Deletes a remote branch
    ///
    /// - Parameter directoryURL: the directory to delete the branch from
    /// - Parameter remoteName: the name of the remote to delete the branch from
    /// - Parameter remoteBranchName: the name of the branch on the remote
    /// 
    /// - Throws: Error
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
    /// - Parameter directoryURL: The directory to search for branches in
    /// - Parameter commitsh: The commit hash to search for
    /// 
    /// - Returns: The names of the branches that point at the given commit
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

    /// Get the name of the branch that the given branch is tracking
    func getMergedBranches() {}
}
