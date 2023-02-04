//
//  NeverShowAgainScope.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 03/02/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

enum NeverShowAgainScope {

    /// Will never show this notification on the current workspace again.
    case WORKSPACE

    /// Will never show this notification on any workspace of the same
    /// profile again.
    ///
    /// TODO: Implement the profile feature for AE
    case PROFILE

    /// Will never show this notification on any workspace across all
    /// profiles again.
    case APPLICATION
}
