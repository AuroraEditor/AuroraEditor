//
//  AELoginModel.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/10/28.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

struct AELogin: Codable {
    let user: AEUser
    let accessToken: String
    let refreshToken: String
}
