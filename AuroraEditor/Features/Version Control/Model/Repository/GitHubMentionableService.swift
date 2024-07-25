//
//  GitHubMentionableService.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/15.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation
import Version_Control

struct QueryCache: Codable {
    var repository: String
    var repoId: Int
    var users: [MentionableUser]
}

class GitHubMentionableService {
    private var database: GitHubUserDatabase
    private let MaxFetchFrequency: TimeInterval = 3600
    private let DefaultMaxHits = 20

    private var queryCache: QueryCache?
    private var pruneQueryCacheTimeoutId: Timer?
    private let QueryCacheTimeout: TimeInterval = 60 * 5 // 5 minutes

    init(database: GitHubUserDatabase) {
        self.database = database
    }

    /**
     * Update the mentionable users for the repository.
     */
    func updateMentionables(
        owner: String,
        name: String,
        repoId: Int,
        account: String
    ) throws {
        let cacheEntry = try database.getMentionableCacheEntry(
            gitHubRepositoryID: repoId
        )

        if let cacheEntry = cacheEntry,
           Date().timeIntervalSince1970 - TimeInterval(cacheEntry.lastUpdated) < MaxFetchFrequency {
            return
        }

        let response = try GitHubAPI().fetchMentionables(
            owner: owner,
            name: name,
            etag: cacheEntry?.eTag
        )

        if response == nil {
            do {
                try database.touchMentionableCacheEntry(
                    gitHubRepositoryID: repoId,
                    eTag: cacheEntry?.eTag
                )
            } catch {
                print("Error: \(error)")
            }
        }

        let mentionables = response?.users.map { user -> MentionableUser in
            return MentionableUser(
                login: user.login,
                name: user.name,
                email: user.email,
                avatar_url: user.avatar_url,
                gitHubRepositoryID: repoId
            )
        } ?? []

        try database.updateMentionablesForRepository(
            gitHubRepositoryID: repoId,
            mentionables: mentionables,
            eTag: response?.etag
        )

        if queryCache?.repoId == repoId {
            queryCache = nil
            clearCachePruneTimeout()
        }
    }

    /**
     * Get the mentionable users in the repository.
     */
    func getMentionableUsers(repoId: Int) throws -> [MentionableUser] {
        return try database.getAllMentionablesForRepository(
            gitHubRepositoryID: repoId
        )
    }

    /**
     * Get the mentionable users which match the text in some way.
     *
     * Hit results are ordered by how close in the search string
     * they matched. Search strings start with username and are followed
     * by real name. Only the first substring hit is considered
     *
     * - Parameters:
     *   - repository: The GitHubRepository for which to look up mentionables.
     *   - query: A string to use when looking for a matching user.
     *   - maxHits: The maximum number of hits to return.
     */
    func getMentionableUsersMatching(
        owner: String,
        name: String,
        repoId: Int,
        query: String,
        maxHits: Int = 20
    ) throws -> [MentionableUser] {
        let users: [MentionableUser]
        if queryCache?.repoId == repoId {
            users = queryCache!.users
        } else {
            users = try getMentionableUsers(repoId: repoId)
            setQueryCache(
                repository: "\(owner)/\(name)",
                repoId: repoId,
                users: users
            )
        }

        let needle = query.lowercased()
        var hits = [(user: MentionableUser, ix: Int)]()

        for user in users {
            let searchString = "\(user.login) \(user.name ?? "")".lowercased()
            if let ix = searchString.range(of: needle)?.lowerBound.utf16Offset(in: searchString) {
                hits.append((user, ix))
            }
        }

        return hits
            .sorted { ($0.ix, $0.user.login) < ($1.ix, $1.user.login) }
            .prefix(maxHits)
            .map { $0.user }
    }

    private func setQueryCache(
        repository: String,
        repoId: Int,
        users: [MentionableUser]
    ) {
        self.clearCachePruneTimeout()
        self.queryCache = QueryCache(
            repository: repository,
            repoId: repoId,
            users: users
        )
        self.pruneQueryCacheTimeoutId = Timer.scheduledTimer(
            timeInterval: QueryCacheTimeout,
            target: self,
            selector: #selector(pruneQueryCache),
            userInfo: nil,
            repeats: false
        )
    }

    private func clearCachePruneTimeout() {
        if let pruneQueryCacheTimeoutId = pruneQueryCacheTimeoutId {
            pruneQueryCacheTimeoutId.invalidate()
            self.pruneQueryCacheTimeoutId = nil
        }
    }

    // Method to prune the query cache
    @objc private func pruneQueryCache() {
        self.pruneQueryCacheTimeoutId = nil
        self.queryCache = nil
    }
}
