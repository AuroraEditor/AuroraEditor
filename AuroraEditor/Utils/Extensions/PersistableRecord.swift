//
//  PersistableRecord.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/06/29.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import GRDB
import OSLog
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
        let log = Logger(subsystem: "com.auroraeditor", category: "database")

        do {
            let dbQueue = try DatabaseQueue.fetchDatabase()
            try dbQueue.write { database in
                if try model.exists(database) {
                    try model.update(database)
                    log.info("Updated \(Self.databaseTableName) successfully.")
                } else {
                    // Save new record
                    try model.insert(database)
                    log.info("Saved \(Self.databaseTableName) successfully.")
                }
            }
        } catch {
            log.error("Failed to save \(Self.databaseTableName) \(error.localizedDescription).")
        }
    }
}
