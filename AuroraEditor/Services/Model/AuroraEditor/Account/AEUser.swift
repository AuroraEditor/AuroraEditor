//
//  AEUser.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/10/28.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Aurora Editor User
struct AEUser: Codable {
    /// Profile image
    let profileImage: String

    /// Identifier
    let id: String

    /// Email
    let email: String

    /// First name
    let firstName: String

    /// Last name
    let lastName: String

    /// Role
    let role: String
}
