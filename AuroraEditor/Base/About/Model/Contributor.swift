//
//  Contributor.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/01/20.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

struct Contributor: Codable {
  let username: String
  let avatarURL: String

  enum CodingKeys: String, CodingKey {
    case username = "login"
    case avatarURL = "avatar_url"
  }
}
