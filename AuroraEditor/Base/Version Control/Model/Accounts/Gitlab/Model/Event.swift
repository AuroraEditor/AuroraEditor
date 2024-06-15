//
//  Event.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Event Data
open class Event: Codable {

    /// Title
    open var title: String?

    /// Project ID
    open var projectID: Int?

    /// Action Name
    open var actionName: String?

    /// Target ID
    open var targetID: Int?

    /// Target Type
    open var targetType: String?

    /// Author ID
    open var authorID: Int?

    /// Data
    open var data: EventData?

    /// Target Title
    open var targetTitle: String?

    /// Author
    open var author: GitlabUser?

    /// Author Username
    open var authorUsername: String?

    /// Created At
    open var createdAt: Date?

    /// Note
    open var note: EventNote?

    /// Coding Keys
    enum CodingKeys: String, CodingKey {
        case title
        case projectID = "project_id"
        case actionName = "action_name"
        case targetID = "target_id"
        case targetType = "target_type"
        case authorID = "author_id"
        case data
        case targetTitle = "target_title"
        case author
        case authorUsername = "author_username"
        case createdAt = "created_at"
        case note
    }
}
