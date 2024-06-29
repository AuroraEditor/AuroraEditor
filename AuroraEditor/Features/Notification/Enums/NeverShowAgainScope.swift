//
//  NeverShowAgainScope.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

/// An enumeration specifying the scope for marking a notification to never show again.
enum NeverShowAgainScope: Codable {
    /// Indicates that the notification should never show again on the current workspace.
    case WORKSPACE

    /// Indicates that the notification should never show again on any workspace of the same profile.
    ///
    /// TODO: Implement the profile feature for AE (Add more information when implementing this feature).
    case PROFILE

    /// Indicates that the notification should never show again on any workspace across all profiles.
    case APPLICATION
}
