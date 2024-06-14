//
//  AELoginModel.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/10/28.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Aurora Editor Login
struct AELogin: Codable {
    /// User
    let user: AEUser

    /// Access token
    let accessToken: String

    /// Refresh token
    let refreshToken: String
}
