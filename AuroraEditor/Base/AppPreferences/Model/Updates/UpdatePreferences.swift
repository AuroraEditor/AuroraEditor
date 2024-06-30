//
//  UpdatePreferences.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/23.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import GRDB
import OSLog

struct UpdatePreferences: Codable, FetchableRecord, PersistableRecord, DatabaseValueConvertible {
    public var id: Int64 = 1
    /// Check for updates
    public var checkForUpdates: Bool = true
    /// Download updates when available
    public var downloadUpdatesWhenAvailable: Bool = true
    /// The update channel
    public var updateChannel: UpdateChannel = .release
    /// The last time the app checked for updates
    public var lastChecked: Date = Date()

    static let databaseTableName = "UpdatePreferences"
}

/// The update channel
enum UpdateChannel: String, Codable {
    /// The release channel
    case release
    /// The beta channel
    case beta
    /// The nightly channel
    case nightly
}
