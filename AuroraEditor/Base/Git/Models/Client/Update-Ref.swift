//
//  Update-Ref.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/15.
//  Copyright © 2022 Aurora Company. All rights reserved.
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

/// Update the ref to a new value.
///
/// @param ref - The ref to update. Must be fully qualified
/// (e.g., `refs/heads/NAME`).
///
/// @param oldValue - The value we expect the ref to have currently. If it
/// doesn't match, the update will be aborted.
///
/// @param newValue - The new value for the ref.
/// @param reason - The reflog entry.
func updateRef(directoryURL: URL,
               ref: String,
               oldValue: String,
               newValue: String,
               reason: String) throws {
    try ShellClient().run(
        // swiftlint:disable:next line_length
        "cd \(directoryURL.relativePath.escapedWhiteSpaces());git update-ref \(ref) \(newValue) \(oldValue) -m \(reason)")
}
/// Remove a ref.
///
/// @param ref - The ref to remove. Should be fully qualified, but may also be 'HEAD'.
/// @param reason - The reflog entry (optional). Note that this is only useful when
/// deleting the HEAD reference as deleting any other reference will
/// implicitly delete the reflog file for that reference as well.
func deleteRef(directoryURL: URL,
               ref: String,
               reason: String?) throws {
    var args = ["update-ref", "-d", ref]

    if reason != nil {
        args.append("-m")
        args.append(reason!)
    }
    try ShellClient().run(
        "cd \(directoryURL.relativePath.escapedWhiteSpaces());git \(args)")
}
