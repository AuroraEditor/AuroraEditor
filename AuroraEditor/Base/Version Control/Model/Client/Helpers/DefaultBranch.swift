//
//  DefaultBranch.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/13.
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

/// Default branch
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

    // TODO: Bug where global config value is not being processed correctly
    /// Returns the configured default branch when creating new repositories
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
