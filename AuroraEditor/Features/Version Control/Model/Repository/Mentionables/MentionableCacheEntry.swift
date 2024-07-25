//
//  MentionableCacheEntry.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/15.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import GRDB

/**
 * An object containing information about when a specific
 * repository's mentionable users was last fetched and
 * the ETag of that request.
 */
public struct MentionableCacheEntry: Codable, FetchableRecord, PersistableRecord  {
    var gitHubRepositoryID: Int
    /**
     * The time (in milliseconds since the epoch) that
     * the mentionable users was last updated for this
     * repository
     */
    var lastUpdated: Int
    /**
     * The ETag returned by the server the last time
     * we issued a request to get the mentionable users
     */
    var eTag: String?

    public static let databaseTableName = "MentionableCacheEntry"
}
