//
//  RM.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/13.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

/// Remove all files from the index
func unstageAllFiles(directoryURL: URL) throws {
    _ = try ShellClient.live().run(
        // these flags are important:
        // --cached - to only remove files from the index
        // -r - to recursively remove files, in case files are in folders
        // -f - to ignore differences between working directory and index
        //          which will block this
        "cd \(directoryURL.relativePath.escapedWhiteSpaces());git rm -cached -r -f .")
}

/// Remove conflicted file from  working tree and index
func removeConflictedFile(directoryURL: URL,
                          file: FileItem) throws {
    _ = try ShellClient.live().run(
        "cd \(directoryURL.relativePath.escapedWhiteSpaces());git rm --\(file.url)")
}
