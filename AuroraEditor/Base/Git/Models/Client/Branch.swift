//
//  Branch.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/12.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

public struct Branches {

    func getBranches(_ allBranches: Bool = false, directoryURL: URL) throws -> [String] {
        if allBranches == true {
            return try ShellClient.live().run(
                "cd \(directoryURL.relativePath.escapedWhiteSpaces());git branch -a --format \"%(refname:short)\""
            )
                .components(separatedBy: "\n")
                .filter { !$0.isEmpty }
        }
        return try ShellClient.live().run(
            "cd \(directoryURL.relativePath.escapedWhiteSpaces());git branch --format \"%(refname:short)\""
        )
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }
    }

    func createBranch() {}

    func renameBranch() {}

    func deleteLocalBranch() {}

    func deleteRemoteBranch() {}

    func getBranchesPointedAt() {}

    func getMergedBranches() {}
}
