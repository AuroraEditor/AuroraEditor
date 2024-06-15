//
//  Tag.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/12.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

/// GIT tag
public struct Tag {
    /// Create a new tag on the given target commit.
    ///
    /// - Parameter directoryURL: The project url
    /// - Parameter name: The name of the new tag.
    /// - Parameter targetCommitSha: The SHA of the commit where the new tag will live on.
    /// 
    /// - Throws: Error
    func createTag(directoryURL: URL,
                   name: String,
                   targetCommitSha: String) throws {
        try ShellClient().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git tag -a -m \(name) \(targetCommitSha) "
        )
    }

    /// Delete a Tag
    ///
    /// - Parameter directoryURL: The project url
    /// - Parameter name: The name of the tag to delete.
    /// 
    /// - Throws: Error
    func deleteTag(directoryURL: URL, name: String) throws {
        try ShellClient().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git tag -d \(name)"
        )
    }

    /// Gets all the local tags. Returns a Map with the tag name and the commit it points to.
    /// 
    /// - Parameter directoryURL: The project url
    /// 
    /// - Returns: The tags as a map.
    func getAllTags(directoryURL: URL) throws -> [String: String] {
        let tags = try ShellClient.live().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git show-ref --tags -d"
        )

        // TODO: Find a way to convert string to dictionary
        return [:]
    }

    /// Fetches the tags that will get pushed to the remote repository.
    ///
    /// - Parameter directoryURL: The project url
    /// - Parameter remote: The remote to check for unpushed tags
    /// - Parameter branchName: The branch that will be used on the push command
    /// 
    /// - Returns: The tags that will be pushed.
    /// 
    /// - Throws: Error
    func fetchTagsToPush(directoryURL: URL,
                         remote: GitRemote,
                         branchName: String) throws -> [String] {
        let args: [Any] = [
            gitNetworkArguments,
            "push",
            remote.name,
            branchName,
            "--follow-tags",
            "--dry-run",
            "--no-verify",
            "--porcelain"
        ]

        let result = try ShellClient.live().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git \(args)"
        )

        let lines = result.split(separator: "\n").map { String($0) }
        var currentLine = 1
        var unpushedTags: [String] = []

        while currentLine < lines.count && lines[currentLine] != "Done" {
            let line = lines[currentLine]
            let parts = line

            if parts.substring(0) == "*" && parts.substring(2) == "[new tag]" {
                let tagName = parts.substring(1).split(separator: ":").map {
                    String($0)
                }

                if !tagName.description.isEmpty {
                    unpushedTags.append(tagName.description.replacingOccurrences(of: "/^refs\\/tags\\//", with: ""))
                }
            }
            currentLine += 1
        }

        return unpushedTags
    }
}
