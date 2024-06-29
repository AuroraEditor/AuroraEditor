//
//  Checkout.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/12.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

/// GIT Checkout
public struct Checkout {

    /// Check out the given branch.
    ///
    /// - Parameter directoryURL: The directory to check out the branch in
    /// - Parameter branch: The name of the branch to check out
    /// 
    /// - Throws: Error
    func checkoutBranch(directoryURL: URL, branch: String) throws {
        try ShellClient.live().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git checkout \(branch)"
        )
    }

    /// Check out the paths at HEAD.
    /// 
    /// - Parameter directoryURL: The directory to check out the paths in
    /// - Parameter paths: The paths to check out
    /// 
    /// - Throws: Error
    func checkoutPaths(directoryURL: URL, paths: [String]) throws {
        try ShellClient.live().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git checkout HEAD --\(paths)"
        )
    }

    /// Check out either stage #2 (ours) or #3 (theirs) for a conflicted file.
    func checkoutConflictedFile() {}
}
