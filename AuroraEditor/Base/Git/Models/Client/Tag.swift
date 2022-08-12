//
//  Tag.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/12.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

public struct Tag {

    /// Create a new tag on the given target commit.
    ///
    /// @param name - The name of the new tag.
    /// @param targetCommitSha  - The SHA of the commit where the new tag will live on.
    func createTag(directoryURL: URL,
                   name: String,
                   targetCommitSha: String) throws {
        let output = try ShellClient.live().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git tag -a -m \(name) \(targetCommitSha) "
        )
    }

    /// Delete a Tag
    ///
    /// @param name - The name of the tag to delete.
    func deleteTag(directoryURL: URL, name: String) throws {
        let output = try ShellClient.live().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git tag -d \(name)"
        )
    }

    /// Gets all the local tags. Returns a Map with the tag name and the commit it points to.
    func getAllTags(directoryURL: URL) throws {
        let output = try ShellClient.live().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git show-ref --tags -d"
        )
    }

    /// Fetches the tags that will get pushed to the remote repository.
    func fetchTagsToPush() {}
}
