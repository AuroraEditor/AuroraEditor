//
//  Stash.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/12.
//  Copyright © 2022 Aurora Company. All rights reserved.
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

public struct Stash {

    let editorStashEntryMarker = "!!AuroraEditor"

    let editorStashEntryMessageRe = "/!!AuroraEditor<(.+)>$/"

    class StashResult {
        /// The stash entries created by Desktop
        var aeEntries: [StashEntry]
        /// The total amount of stash entries,
        /// i.e. stash entries created both by AE and outside of AE
        var stashEntryCount: Int

        init(aeEntries: [StashEntry], stashEntryCount: Int) {
            self.aeEntries = aeEntries
            self.stashEntryCount = stashEntryCount
        }
    }

    /// Get the list of stash entries created by Desktop in the current repository
    /// using the default ordering of refs (which is LIFO ordering),
    /// as well as the total amount of stash entries.
    @discardableResult
    func getStashes(directoryURL: URL) throws -> StashResult {
        let delimiter = "1F"
        let delimiterString = String(UnicodeScalar(UInt8(16)))
        let format = ["%gD", "%H", "%gs"].joined(separator: "%x\(delimiter)")

        let output = try ShellClient.live().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git log -g -z --pretty\(format) refs/stash"
        )

        var aeStashEntires: [StashEntry] = []
        var files: FileItem

        let entries = output.split(separator: "\0").filter { $0.isEmpty }
        for entry in entries {
            let branchName = extractBranchFromMessage(message: "")

            if branchName != nil {
                aeStashEntires.append(StashEntry(name: "",
                                                 branchName: branchName,
                                                 stashSha: "",
                                                 files: nil))
            }
        }

        return StashResult(aeEntries: aeStashEntires,
                           stashEntryCount: entries.count - 1)
    }

    /// Returns the last AE created stash entry for the given branch
    func getLastAEStashEntryForBranch(directoryURL: URL,
                                      branch: String) throws {
        let stash = try getStashes(directoryURL: directoryURL)
        let branchName = branch
    }

    /// Creates a stash entry message that indicates the entry was created by Aurora Editor
    func createAEStashMessage(branchName: String) -> String {
        return "\(editorStashEntryMarker)\(branchName)"
    }

    /// Stash the working directory changes for the current branch
    func createAEStashEntry(directoryURL: URL,
                            branch: String,
                            untrackedFilesToStage: [FileItem]) throws -> Bool {

        try stageFiles(directoryURL: directoryURL, files: untrackedFilesToStage)

        let branchName = branch
        let message = createAEStashMessage(branchName: branchName)
        let args = ["stash", "push", "-m", message]

        let result = try ShellClient.live().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git \(args)")

        // Stash doesn't consider it an error that there aren't any local changes to save.
        if result.contains("No local changes to save\n") {
            return false
        }

        return true
    }

    private func getStashEntryMatchingSha(directoryURL: URL, sha: String) throws -> String? {
        try getStashes(directoryURL: directoryURL)
        return ""
    }

    /// Removes the given stash entry if it exists
    ///
    /// @param stashSha the SHA that identifies the stash entry
    func dropAEStashEntry(directoryURL: URL, sha: String) throws {
        let entryToDelete = try getStashEntryMatchingSha(directoryURL: directoryURL,
                                                         sha: sha)

        if entryToDelete != nil {
            let args = ["stash", "drop", entryToDelete]
            try ShellClient.live().run(
                "cd \(directoryURL.relativePath.escapedWhiteSpaces());git \(args)")
        }
    }

    /// Pops the stash entry identified by matching `stashSha` to its commit hash.
    ///
    /// To see the commit hash of stash entry, run
    /// `git log -g refs/stash --pretty="%nentry: %gd%nsubject: %gs%nhash: %H%n"`
    /// in a repo with some stash entries.
    func popStashEntry(directoryURL: URL, sha: String) throws {
        let stashToPop = try getStashEntryMatchingSha(directoryURL: directoryURL, sha: sha)

        if let stashToPop = stashToPop {
            let args = ["stash", "pop", "--quiet", "\(stashToPop)"]
            try ShellClient.live().run(
                "cd \(directoryURL.relativePath.escapedWhiteSpaces());git \(args)")

            try dropAEStashEntry(directoryURL: directoryURL, sha: sha)
        }
    }

    private func extractBranchFromMessage(message: String) -> String? {
        let match = editorStashEntryMessageRe
        return match.substring(1).isEmpty ? nil : match.substring(1)
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

        try ShellClient.live().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git \(args)"
        )
    }
}
