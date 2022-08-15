//
//  Diff.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/15.
//  Copyright © 2022 Aurora Company. All rights reserved.
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

/// This is a hard limit on how big a buffer can be and still be converted into
/// a string.
let maxDiffBufferSize = 70e6 // 70MB in decimal

/// Where `MaxDiffBufferSize` is a hard limit, this is a suggested limit. Diffs
/// bigger than this _could_ be displayed but it might cause some slowness.
let maxReasonableDiffSize = maxDiffBufferSize / 16 // ~4.375MB in decimal

/// The longest line length we should try to display. If a diff has a line longer
/// than this, we probably shouldn't attempt it
let maxCharactersPerLine = 5000

/// Render the diff for a file within the repository working directory. The file will be
/// compared against HEAD if it's tracked, if not it'll be compared to an empty file meaning
/// that all content in the file will be treated as additions.
func getWorkingDirectoryDiff(workspaceURL: URL,
                             file: FileItem,
                             hideWhitespaceInDiff: Bool = false) throws {
    var args: [Any] = [
        "diff",
        (hideWhitespaceInDiff ? ["-w"] : []),
        "--no-ext-diff",
        "--patch-with-raw",
        "-z",
        "--no-color"
    ]

    if file.gitStatus == .added || file.gitStatus == .unknown {
        args.append("--no-index")
        args.append("--")
        args.append("/dev/null")
        args.append(file.url)
    } else if file.gitStatus == .renamed {
        args.append("--")
        args.append(file.url)
    } else {
        args.append("HEAD")
        args.append(file.url)
    }
}

/// `git diff` will write out messages about the line ending changes it knows
/// about to `stderr` - this rule here will catch this and also the to/from
/// changes based on what the user has configured.
let lineEndingsChangeRegex = "warning: (CRLF|CR|LF) will be replaced by (CRLF|CR|LF) in .*"
