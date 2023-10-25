//
//  INeverShowAgainOptions.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

/// The `INeverShowAgainOptions` struct represents options to configure whether a notification
/// should never be shown again.
struct INeverShowAgainOptions: Hashable, Equatable, Codable {
    /// The identifier used to persist the selection of not showing the notification again.
    var id: String

    /// Indicates whether the action should be a secondary action. If `true`,
    /// it will be a secondary action; otherwise, it will be a primary action.
    var isSecondary: Bool?

    /// Specifies whether to persist the choice in the current workspace or for all workspaces.
    ///
    /// By default, it will be persisted for all workspaces across all profiles,
    /// which corresponds to `NeverShowAgainScope.APPLICATION`.
    var scope: NeverShowAgainScope?
}
