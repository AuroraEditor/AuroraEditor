//
//  Stash.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/12.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

public struct Stash {

    let editorStashEntryMessageRe = "!!AuroraEditor"

    /// Get the list of stash entries created by Desktop in the current repository
    /// using the default ordering of refs (which is LIFO ordering),
    /// as well as the total amount of stash entries.
    func getStashes(directoryURL: URL) throws {
        let delimiter = "1F"
        let delimiterString = String(UnicodeScalar(UInt8(16)))
        let format = ["%gD", "%H", "%gs"].joined(separator: "%x\(delimiter)")

        let output = try ShellClient.live().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git log -g -z --pretty\(format) refs/stash"
        )
    }

    func getLastAEStashEntryForBranch(directoryURL: URL,
                                      branch: String) throws {
        let stash = try getStashes(directoryURL: directoryURL)
        let branchName = branch
    }

    /// Creates a stash entry message that indicates the entry was created by Aurora Editor
    func createAEStashMessage() {}

    /// Stash the working directory changes for the current branch
    func createAEStashEntry() {}

    private func getStashEntryMatchingSha(directoryURL: URL, sha: String) throws {
        let stash = try getStashes(directoryURL: directoryURL)
    }

    /// Removes the given stash entry if it exists
    ///
    /// @param stashSha the SHA that identifies the stash entry
    func dropAEStashEntry(directoryURL: URL, sha: String) {}

    /// Pops the stash entry identified by matching `stashSha` to its commit hash.
    ///
    /// To see the commit hash of stash entry, run
    /// `git log -g refs/stash --pretty="%nentry: %gd%nsubject: %gs%nhash: %H%n"`
    /// in a repo with some stash entries.
    func popStashEntry(directoryURL: URL, sha: String) {}

    private func extractBranchFromMessage(message: String) -> String? {
        let match = editorStashEntryMessageRe
        return ""
    }

    /// Get the files that were changed in the given stash commit
    func getStashedFiles(directoryURL: URL, stashSha: String) throws {
        let args = ["stash",
                    "show",
                    stashSha,
                    "--raw",
                    "--numstat",
                    "-z",
                    "--format=format:",
                    "--now-show-signature",
                    "--"]

        let output = try ShellClient.live().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git \(args)"
        )
    }
}
