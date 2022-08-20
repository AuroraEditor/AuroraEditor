//
//  RM.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/13.
//  Copyright © 2022 Aurora Company. All rights reserved.
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

/// Remove all files from the index
func unstageAllFiles(directoryURL: URL) {
    do {
        try ShellClient().run(
            // these flags are important:
            // --cached - to only remove files from the index
            // -r - to recursively remove files, in case files are in folders
            // -f - to ignore differences between working directory and index
            //          which will block this
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git rm -cached -r -f .")
    } catch {
        Log.error("Failed to unstage all files")
    }
}

/// Remove conflicted file from  working tree and index
func removeConflictedFile(directoryURL: URL,
                          file: FileItem) throws {
    try ShellClient().run(
        "cd \(directoryURL.relativePath.escapedWhiteSpaces());git rm --\(file.url)")
}
