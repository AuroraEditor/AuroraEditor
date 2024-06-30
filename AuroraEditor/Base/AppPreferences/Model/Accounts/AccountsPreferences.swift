//
//  AccountsPreferences.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/08.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import GRDB

struct AccountPreferences: Codable, FetchableRecord,
                           PersistableRecord, DatabaseValueConvertible,
                           Identifiable, Equatable {
    /// The unique identifier for the account
    public var id: String = ""

    /// The name of the provider
    public var provider: String = ""

    /// The link to the provider
    public var providerLink: String = ""

    /// The description of the provider
    public var providerDescription: String = ""

    /// The name of the account
    public var accountName: String = ""

    /// The email of the account
    public var accountEmail: String = ""

    /// The username of the account
    public var accountUsername: String = ""

    /// The image of the account
    public var accountImage: String = ""

    // If bool we use the HTTP protocol else if false we use SHH
    /// The cloning protocol
    public var gitCloningProtocol: Bool = false

    /// The SSH key of the account
    public var gitSSHKey: String = ""

    /// Is the token valid
    public var isTokenValid: Bool = false

    static let databaseTableName = "AccountPreferences"

    // MARK: - Database Functions

    /// Creates a new account record in the database.
    /// - Parameter account: The `AccountPreferences` instance to save.
    /// - Throws: An error if the database operation fails.
    static func create(account: AccountPreferences) {
        do {
            let dbQueue = try DatabaseQueue.fetchDatabase()
            try dbQueue.write { database in
                try account.save(database)
            }
        } catch {}
    }

    /// Fetches all records from the AccountPreferences table.
    /// - Returns: An array of AccountPreferences instances.
    /// - Throws: An error if the database operation fails.
    static func fetchAll() -> [AccountPreferences] {
        do {
            let dbQueue = try DatabaseQueue.fetchDatabase()
            return try dbQueue.read { database in
                try AccountPreferences.fetchAll(database)
            }
        } catch {
            return []
        }
    }

    /// Checks if the user has any Git accounts.
    /// - Returns: A boolean indicating if any Git accounts exist.
    static func doesUserHaveGitAccounts() -> Bool {
        do {
            let dbQueue = try DatabaseQueue.fetchDatabase()
            return try dbQueue.read { database in
                let count = try Int.fetchOne(database, sql: """
                    SELECT COUNT(*) FROM \(databaseTableName)
                    """) ?? 0
                return count > 0 // swiftlint:disable:this empty_count
            }
        } catch {
            return false
        }
    }

    /// Deletes an account record from the database.
    /// - Parameter account: The `AccountPreferences` instance to delete.
    static func delete(_ account: AccountPreferences) {
        do {
            let dbQueue = try DatabaseQueue.fetchDatabase()
            try dbQueue.write { database in
                try account.delete(database)
            }
        } catch {}
    }
}
