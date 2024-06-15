//
//  EventNote.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Event Note
open class EventNote: Codable {

    /// Identifier
    open var id: Int?

    /// Body
    open var body: String?

    /// Attachment
    open var attachment: String?

    /// Author
    open var author: GitlabUser?

    /// Created At
    open var createdAt: Date?

    /// System
    open var system: Bool?

    /// Upvote
    open var upvote: Bool?

    /// Downvote
    open var downvote: Bool?

    /// Noteable ID
    open var noteableID: Int?

    /// Noteable Type
    open var noteableType: String?

    /// Initialize Event Note
    /// 
    /// - Parameter json: JSON
    /// 
    /// - Returns: Event Note
    public init(_ json: [String: AnyObject]) {
        id = json["id"] as? Int
        body = json["body"] as? String
        attachment = json["attachment"] as? String
        author = GitlabUser(json["author"] as? [String: AnyObject] ?? [:])
        createdAt = Time.rfc3339Date(json["created_at"] as? String)
        system = json["system"] as? Bool
        upvote = json["upvote"] as? Bool
        downvote = json["downvote"] as? Bool
        noteableID = json["noteable_id"] as? Int
        noteableType = json["noteable_type"] as? String
    }
}
