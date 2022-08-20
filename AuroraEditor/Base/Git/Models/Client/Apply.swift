//
//  Apply.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/15.
//  Copyright © 2022 Aurora Company. All rights reserved.
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

func applyPatchToIndex(directoryURL: URL,
                       file: FileItem) throws {
    // If the file was a rename we have to recreate that rename since we've
    // just blown away the index. Think of this block of weird looking commands
    // as running `git mv`.
    if file.gitStatus == .renamed {
        // Make sure the index knows of the removed file. We could use
        // update-index --force-remove here but we're not since it's
        // possible that someone staged a rename and then recreated the
        // original file and we don't have any guarantees for in which order
        // partial stages vs full-file stages happen. By using git add the
        // worst that could happen is that we re-stage a file already staged
        // by updateIndex.
      try ShellClient().run(
        "cd \(directoryURL.relativePath.escapedWhiteSpaces());git add --u \(file.url)")

        // Figure out the blob oid of the removed file
        // <mode> SP <type> SP <object> TAB <file>
        let oldFile = try ShellClient.live().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git ls-tree HEAD --\(file.url)")

        let info = oldFile.split(separator: "\t", maxSplits: 1)
        let mode = info.split(separator: " ", maxSplits: 3)
        let oid = mode

        // Add the old file blob to the index under the new name
        try ShellClient().run(
            // swiftlint:disable:next line_length
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git update-index --add --cacheinfo \(mode) \(oid) \(file.url)")
    }

    let applyArgs: [String] = [
        "apply",
        "--cached",
        "--undiff-zero",
        "--whitespace=nowarn",
        "-"
    ]

    try ShellClient().run(
        "cd \(directoryURL.relativePath.escapedWhiteSpaces());git \(applyArgs)")

}
