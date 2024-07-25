//
//  MentionableUser.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/15.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Version_Control
import GRDB

struct MentionableUser: Codable, FetchableRecord, PersistableRecord {
    /**
     * The username or "handle" of the user
     */
    var login: String
    /**
     * The user's real name (or at least the name that the user
     * has configured to be shown) or null if the user hasn't provided
     * a real name for their public profile.
     */

    var name: String?
    /**
     * The user's attributable email address or null if the
     * user doesn't have an email address that they can be
     * attributed by
     */
    var email: String
    /**
     * A url to an avatar image chosen by the user
     */
    var avatar_url: String
    /**
     * The id corresponding to the dbID property of the
     * `GitHubRepository` instance that this user is associated
     * with
     */
    var gitHubRepositoryID: Int

    static let databaseTableName = "MentionableUser"
}
