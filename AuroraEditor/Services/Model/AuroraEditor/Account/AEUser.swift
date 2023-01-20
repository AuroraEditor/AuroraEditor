//
//  AEUser.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/10/28.
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
