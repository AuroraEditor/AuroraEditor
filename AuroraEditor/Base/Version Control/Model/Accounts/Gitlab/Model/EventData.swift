//
//  EventData.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

@available(*, deprecated, renamed: "VersionControl", message: "This will be deprecated in favor of the new VersionControl Remote SDK APIs.")
/// Event Data
open class EventData: Codable {

    /// Object Kind
    open var objectKind: String?

    /// Event Name
    open var eventName: String?

    /// Before
    open var before: String?

    /// After
    open var after: String?

    /// Reference
    open var ref: String?

    /// Checkout SHA
    open var checkoutSha: String?

    /// Message
    open var message: String?

    /// User ID
    open var userID: Int?

    /// User Name
    open var userName: String?

    /// User Email
    open var userEmail: String?

    /// User Avatar
    open var userAvatar: URL?

    /// Project ID
    open var projectID: Int?

    /// Project
    open var project: Project?

    /// Commits
    open var commits: [GitlabCommit]?

    /// Total Commits Count
    open var totalCommitsCount: Int?

    /// Coding Keys
    enum CodingKeys: String, CodingKey {
        case objectKind = "object_kind"
        case eventName = "event_name"
        case before
        case after
        case ref
        case checkoutSha = "checkout_sha"
        case message
        case userID = "user_id"
        case userName = "user_name"
        case userEmail = "user_email"
        case userAvatar = "user_avater"
        case projectID = "project_id"
        case project
        case commits
        case totalCommitsCount = "total_commits_count"
    }
}
