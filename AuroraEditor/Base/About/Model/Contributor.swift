//
//  Contributor.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/01/20.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// A struct to represent a contributor
/// 
/// This struct represents a contributor to the Aurora Editor project.
public struct Contributor: Codable, Identifiable, Hashable {
    /// The unique identifier for the contributor
    public var id: String { self.username }

    /// The username of the contributor
    let username: String

    /// The URL to the avatar of the contributor
    let avatarURL: String

    /// The keys for decoding the JSON
    enum CodingKeys: String, CodingKey {
        case username = "login"
        case avatarURL = "avatar_url"
    }
}
