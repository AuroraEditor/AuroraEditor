//
//  Update-Ref.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/15.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

/// Update the ref to a new value.
///
/// - Parameter directoryURL: The directory to update the ref in.
/// - Parameter ref: The ref to update. Must be fully qualified
///                  (e.g., `refs/heads/NAME`).
/// - Parameter oldValue: The value we expect the ref to have currently. If it
///                       doesn't match, the update will be aborted.
/// - Parameter newValue: The new value for the ref.
/// - Parameter reason: The reflog entry.
/// 
/// - Throws: Error
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
/// - Parameter directoryURL: The directory to remove the ref from.
/// - Parameter ref: The ref to remove. Should be fully qualified, but may also be 'HEAD'.
/// - Parameter reason: The reflog entry (optional). Note that this is only useful when
///                     deleting the HEAD reference as deleting any other reference will
///                     implicitly delete the reflog file for that reference as well.
/// 
/// - Throws: Error
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
