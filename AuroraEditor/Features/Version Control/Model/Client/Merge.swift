//
//  Merge.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/13.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

/// The result of a merge operation
enum MergeResult {
    /// The merge completed successfully
    case success

    /// The merge was a noop since the current branch
    /// was already up to date with the target branch.
    case alreadyUpToDate

    /// The merge failed, likely due to conflicts.
    case failed
}

/// Merge the named branch into the current branch.
/// 
/// - Parameter directoryURL: The project url
/// - Parameter branch: The branch to merge
/// - Parameter isSquash: Whether to squash the merge
/// 
/// - Returns: The result of the merge operation
/// 
/// - Throws: Error
func merge(directoryURL: URL,
           branch: String,
           isSquash: Bool = false) throws -> MergeResult {
    var args = ["merge"]

    if isSquash {
        args.append("--squash")
    }

    args.append(branch)

    let result = try ShellClient.live().run(
        "cd \(directoryURL.relativePath.escapedWhiteSpaces());git \(args)"
    )

    if isSquash {
        let result = try ShellClient.live().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git commit --no-edit"
        )
    }

    return result == noopMergeMessage ? MergeResult.alreadyUpToDate : MergeResult.success
}

/// Already up to date message
let noopMergeMessage = "Already up to date.\n"

/// Find the base commit between two commit sha identifiers
/// 
/// - Parameter directoryURL: The project url
/// - Parameter firstCommitish: The first commit sha
/// - Parameter secondCommitish: The second commit sha
/// 
/// - Returns: The base commit
/// 
/// - Throws: Error
func getMergeBase(directoryURL: URL,
                  firstCommitish: String,
                  secondCommitish: String) throws -> String? {
    let process = try ShellClient.live().run(
        "cd \(directoryURL.relativePath.escapedWhiteSpaces());git merge-base \(firstCommitish) \(secondCommitish)"
    )

    return process.trimmingCharacters(in: .whitespaces)
}

/// Abort a mid-flight (conflicted) merge
/// 
/// - Parameter directoryURL: The project url
/// 
/// - Throws: Error
func abortMerge(directoryURL: URL) throws {
    _ = try ShellClient.live().run(
        "cd \(directoryURL.relativePath.escapedWhiteSpaces());git merge --abort"
    )
}

/// Check the `.git/MERGE_HEAD` file exists in a repository to confirm
/// that it is in a conflicted state.
/// 
/// - Parameter directoryURL: The project url
/// 
/// - Returns: True if the repository is in a conflicted state
/// 
/// - Throws: Error
func isMergeHeadSet(directoryURL: URL) throws -> Bool {
    let path = try String(contentsOf: directoryURL) + ".git/MERGE_HEAD"
    return FileManager.default.fileExists(atPath: path)
}

/// Check the `.git/SQUASH_MSG` file exists in a repository
/// This would indicate we did a merge --squash and have not committed.. indicating
/// we have detected a conflict.
///
/// Note: If we abort the merge, this doesn't get cleared automatically which
/// could lead to this being erroneously available in a non merge --squashing scenario.
/// 
/// - Parameter directoryURL: The project url
/// 
/// - Returns: True if the squash message file exists
/// 
/// - Throws: Error
func isSquashMsgSet(directoryURL: URL) throws -> Bool {
    let path = try String(contentsOf: directoryURL) + ".git/SQUASH_MSG"
    return FileManager.default.fileExists(atPath: path)
}
