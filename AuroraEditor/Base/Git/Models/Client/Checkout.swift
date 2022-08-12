//
//  Checkout.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/12.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

public struct Checkout {

    ///
    /// Check out the given branch.
    ///
    /// @param repository - The repository in which the branch checkout should
    ///                take place
    /// @param branch - The branch name that should be checked out
    /// @param progressCallback - An optional function which will be invoked
    ///                     with information about the current progress
    ///                     of the checkout operation. When provided this
    ///                     enables the '--progress' command line flag for
    ///                     'git checkout'.
    ///
    func checkoutBranch() {}

    /// Check out the paths at HEAD.
    func checkoutPaths(directoryURL: URL, paths: [String]) throws {
        let output = try ShellClient.live().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git checkout HEAD --\(paths)"
        )
    }

    /// Check out either stage #2 (ours) or #3 (theirs) for a conflicted file.
    func checkoutConflictedFile() {}
}
