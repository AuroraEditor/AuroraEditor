//
//  PersistableRecord.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/06/29.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import GRDB
import os.log
import Foundation

/// Extension on `PersistableRecord` protocol to provide a utility
/// method for saving or updating records in a database.
///
/// This extension adds a static method `saveOrUpdate` that determines whether to save
/// a new record or update an existing one based on its existence in the database.
///
/// - Parameters:
///   - model: The model conforming to `PersistableRecord` and `TableRecord`
///            protocols to be saved or updated.
extension PersistableRecord where Self: TableRecord {
    static func saveOrUpdate(_ model: Self) {
        let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "database")

        do {
            let dbQueue = try DatabaseQueue.fetchDatabase()
            try dbQueue.write { database in
                if try model.exists(database) {
                    try model.update(database)
                    os_log(
                        "Updated %@ successfully.",
                        log: log,
                        type: .info,
                        Self.databaseTableName
                    )
                } else {
                    // Save new record
                    try model.insert(database)
                    os_log(
                        "Saved %@ successfully.",
                        log: log,
                        type: .info,
                        Self.databaseTableName
                    )
                }
            }
        } catch {
            os_log(
                "Failed to save %@: %@",
                log: log,
                type: .error,
                Self.databaseTableName,
                error.localizedDescription
            )
        }
    }
}
