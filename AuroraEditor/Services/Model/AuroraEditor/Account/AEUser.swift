//
//  AEUser.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/10/28.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

struct AEUser: Codable {
    let profileImage: String
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let role: String
}
