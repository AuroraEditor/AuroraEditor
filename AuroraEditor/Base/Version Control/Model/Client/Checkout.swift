//
//  Checkout.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/12.
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

/// GIT Checkout
public struct Checkout {

    /// Check out the given branch.
    ///
    /// @param repository - The repository in which the branch checkout should
    ///                take place
    /// @param branch - The branch name that should be checked out
    func checkoutBranch(directoryURL: URL, branch: String) throws {
        try ShellClient.live().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git checkout \(branch)"
        )
    }

    /// Check out the paths at HEAD.
    func checkoutPaths(directoryURL: URL, paths: [String]) throws {
        try ShellClient.live().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git checkout HEAD --\(paths)"
        )
    }

    /// Check out either stage #2 (ours) or #3 (theirs) for a conflicted file.
    func checkoutConflictedFile() {}
}
