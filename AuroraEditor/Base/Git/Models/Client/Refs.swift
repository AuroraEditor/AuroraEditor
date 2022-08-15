//
//  Refs.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/12.
//  Copyright © 2022 Aurora Company. All rights reserved.
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

public struct Refs {

    /// Format a local branch in the ref syntax, ensuring situations when the branch
    /// is ambiguous are handled.
    ///
    /// Examples:
    /// - main -> refs/heads/main
    /// - heads/AuroraEditor/main -> refs/heads/AuroraEditor/main
    ///
    /// @param name - The local branch name
    func formatAsLocalRef(name: String) -> String {
        if name.starts(with: "heads/") {
            // In some cases, Git will report this name explicitly to distinguish from
            // a remote ref with the same name - this ensures we format it correctly.
            return "refs/\(name)"
        } else if !(name.starts(with: "refs/heads/")) {
            // By default Git will drop the heads prefix unless absolutely necessary
            // - include this to ensure the ref is fully qualified.
            return "refs/heads/\(name)"
        } else {
            return name
        }
    }

    /// Read a symbolic ref from the repository.
    ///
    /// Symbolic refs are used to point to other refs, similar to how symlinks work
    /// for files. Because refs can be removed easily from a Git repository,
    /// symbolic refs should only be used when absolutely necessary.
    ///
    /// @param directoryURL - The project url
    ///
    /// @param - ref The symbolic ref to resolve
    ///
    /// @returns - the canonical ref, if found, or `nil` if `ref` cannot be found or
    /// is not a symbolic ref
    func getSymbolicRef(directoryURL: URL,
                        ref: String) throws -> String? {
        let result = try ShellClient.live().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git symbolic-ref -q \(ref)"
        )

        return result.trimmingCharacters(in: .whitespaces)
    }
}
