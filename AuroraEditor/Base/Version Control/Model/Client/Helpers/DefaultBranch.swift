//
//  DefaultBranch.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/13.
//  Copyright © 2022 Aurora Company. All rights reserved.
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

public struct DefaultBranch {

    /// The default branch name that GitHub Desktop will use when
    /// initializing a new repository.
    let defaultBranchInAE = "main"

    /// The name of the Git configuration variable which holds what
    /// branch name Git will use when initializing a new repository.
    let defaultBranchSettingName = "init.defaultBranch"

    /// The branch names that Aurora Editor shows by default as radio buttons on the
    /// form that allows users to change default branch name.
    let suggestedBranchNames: [String] = ["main, master"]

    /// Returns the configured default branch when creating new repositories
    // TODO: Bug where global config value is not being processed correctly
    func getConfiguredDefaultBranch() throws -> String? {
        return try getGlobalConfigVlaue(name: defaultBranchSettingName)
    }

    /// Returns the configured default branch when creating new repositories
    func getDefaultBranch() throws -> String {
        // return try getConfiguredDefaultBranch() ?? defaultBranchInAE
        return defaultBranchInAE
    }

    /// Sets the configured default branch when creating new repositories.
    ///
    /// @param branchName - The default branch name to use.
    func setDefaultBranch(branchName: String) throws -> String {
        return try setGlobalConfigValue(name: defaultBranchSettingName,
                                    value: branchName)
    }

}
