//
//  INeverShowAgainOptions.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

struct INeverShowAgainOptions: Hashable, Equatable {

    /// The id is used to persist the selection of not showing the notification again.
    var id: String

    /// By default the action will show up as primary action. Setting this to true will
    /// make it a secondary action instead.
    var isSecondary: Bool?

    /// Whether to persist the choice in the current workspace or for all workspaces. By
    /// default it will be persisted for all workspaces across all profiles
    /// (= `NeverShowAgainScope.APPLICATION`).
    var scope: NeverShowAgainScope?
}
