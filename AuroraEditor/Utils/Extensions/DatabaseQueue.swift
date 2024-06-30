//
//  DatabaseQueue.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/06/29.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import GRDB
import Foundation

extension DatabaseQueue {
    /// Fetches the database queue at the preferences database path.
    /// - Returns: The fetched `DatabaseQueue` instance.
    /// - Throws: An error if the database queue cannot be fetched.
    static func fetchDatabase() throws -> DatabaseQueue {
        let databasePath = try FileManager.preferencesDatabasePath()
        let dbQueue = try DatabaseQueue(path: databasePath)
        return dbQueue
    }
}
