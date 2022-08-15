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

    let defaultBranchInAE = "main"
    let defaultBranchSettingName = "init.defaultBranch"
    let suggestedBranchNames: [String] = ["main, master"]

    func getConfiguredDefaultBranch() -> String {
        return ""
    }

    func getDefaultBranch() -> String {
        return ""
    }

    func setDefaultBranch() -> String {
        return ""
    }

}
