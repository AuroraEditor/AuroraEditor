//
//  GitHubUserDatabase.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/15.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import GRDB
import os
import Foundation

struct GitHubUserDatabase {
    static let logger = Logger(
        subsystem: "com.auroraeditor",
        category: "GitHubUserDatabase"
    )

    /// Sets up the database queue and creates necessary tables if they do not exist.
    ///
    /// - Parameter path: The file path where the SQLite database should be located.
    /// - Returns: A `DatabaseQueue` instance ready for use.
    static func setupDatabase(at path: String) throws -> DatabaseQueue {
        let dbQueue = try DatabaseQueue(path: path)
        try createTables(in: dbQueue)
        return dbQueue
    }

    /// Creates tables for various preferences using the provided database queue.
    ///
    /// - Parameter dbQueue: The `DatabaseQueue` instance to execute table creation.
    private static func createTables(in dbQueue: DatabaseQueue) throws {
        do {
            try dbQueue.write { database in
                do {
                    try database.create(
                        table: MentionableUser.databaseTableName,
                        ifNotExists: true
                    ) { table in
                        table.column("id", .integer).primaryKey()
                        table.column("login", .text)
                        table.column("name", .text)
                        table.column("email", .text)
                        table.column("avatar_url", .text)
                        table.column("gitHubRepositoryID", .integer)
                    }
                } catch {
                    logger.error("Failed to create MentionableUserDB table: \(error.localizedDescription)")
                }

                do {
                    try database.create(
                        table: MentionableCacheEntry.databaseTableName,
                        ifNotExists: true
                    ) { table in
                        table.column("id", .integer).primaryKey()
                        table.column("gitHubRepositoryID", .integer)
                        table.column("lastUpdated", .integer)
                        table.column("eTag", .text)
                    }
                } catch {
                    logger.error("Failed to create IMentionableCacheEntry table: \(error.localizedDescription)")
                }
            }
        } catch {
            logger.error("Failed to write to database: \(error.localizedDescription)")
            throw error
        }
    }

    /**
     * Persist all the mentionable users provided for the given
     * gitHubRepositoryID and update the lastUpdated property and
     * ETag for the mentionable cache entry.
     */
    func updateMentionablesForRepository(
        gitHubRepositoryID: Int,
        mentionables: [MentionableUser],
        eTag: String?
    ) throws {
        try DatabaseQueue.fetchGitHubDatabase().write { database in
            // Delete existing mentionables for the repository
            try MentionableUser
                .filter(Column("gitHubRepositoryID") == gitHubRepositoryID)
                .deleteAll(database)

            // Update the cache entry for the repository
            let cacheEntry = MentionableCacheEntry(
                gitHubRepositoryID: gitHubRepositoryID,
                lastUpdated: Int(Date().timeIntervalSince1970),
                eTag: eTag
            )
            try cacheEntry.insert(database)

            // Add new mentionables
            for mentionable in mentionables {
                var mentionableToAdd = mentionable
                mentionableToAdd.gitHubRepositoryID = gitHubRepositoryID
                try mentionableToAdd.insert(database)
            }
        }
    }

    /// Retrieves all persisted mentionable users for the provided `gitHubRepositoryID`.
    ///
    /// - Parameter gitHubRepositoryID: The ID of the GitHub repository.
    /// - Returns: An array of `MentionableUser` associated with the repository.
    func getAllMentionablesForRepository(
        gitHubRepositoryID: Int
    ) throws -> [MentionableUser] {
        return try DatabaseQueue.fetchGitHubDatabase().read { db in
            try MentionableUser
                .filter(Column("gitHubRepositoryID") == gitHubRepositoryID)
                .fetchAll(db)
        }
    }

    /// Get the cache entry (or undefined if no cache entry has
    /// been written yet) for the `gitHubRepositoryID`. The
    /// cache entry contains information on when the repository
    /// mentionables was last refreshed as well as the ETag of
    /// he previous request.
    ///
    /// - Parameter gitHubRepositoryID: The ID of the GitHub repository.
    /// - Returns: An optional `MentionableCacheEntry` if it exists.
    func getMentionableCacheEntry(
        gitHubRepositoryID: Int
    ) throws -> MentionableCacheEntry? {
        return try DatabaseQueue.fetchGitHubDatabase().read { db in
            try MentionableCacheEntry
                .filter(Column("gitHubRepositoryID") == gitHubRepositoryID)
                .fetchOne(db)
        }
    }

    /// Updates the lastUpdated property for the cache entry to the current time and sets the ETag.
    ///
    /// - Parameters:
    ///   - gitHubRepositoryID: The ID of the GitHub repository.
    ///   - eTag: An optional ETag value for caching purposes.
    /// - Throws: An error if any database operation fails.
    func touchMentionableCacheEntry(
        gitHubRepositoryID: Int,
        eTag: String?
    ) throws {
        let lastUpdated = Int(Date().timeIntervalSince1970)
        let entry = MentionableCacheEntry(
            gitHubRepositoryID: gitHubRepositoryID,
            lastUpdated: lastUpdated,
            eTag: eTag
        )

        try DatabaseQueue.fetchGitHubDatabase().write { db in
            try entry.insert(db)
        }
    }
}
