//
//  Comment.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

@available(*, deprecated, renamed: "VersionControl", message: "This will be deprecated in favor of the new VersionControl Remote SDK APIs.")
/// Github comment
public struct Comment: Codable {

    /// Comment Identifier
    public let id: Int

    /// Comment URL
    public let url: URL

    /// Comment HTML URL
    public let htmlURL: URL

    /// Comment body
    public let body: String

    /// Comment user
    public let user: GithubUser

    /// Comment created at
    public let createdAt: Date

    /// Comment updated at
    public let updatedAt: Date

    /// Coding keys
    enum CodingKeys: String, CodingKey {
        case id, url, body, user
        case htmlURL = "html_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
