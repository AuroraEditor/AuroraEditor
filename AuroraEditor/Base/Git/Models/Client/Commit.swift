//
//  Commit.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/12.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

public struct Commit {

    /// @param repository repository to execute merge in
    /// @param message commit message
    /// @param files files to commit
    /// @returns the commit SHA
    func createCommit() {}

    /// Creates a commit to finish an in-progress merge
    /// assumes that all conflicts have already been resolved
    ///
    /// @param repository repository to execute merge in
    /// @param files files to commit
    func createMergeCommit() {}
}
