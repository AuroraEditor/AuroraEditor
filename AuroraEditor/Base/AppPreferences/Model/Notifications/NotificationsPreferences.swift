//
//  NotificationsPreferences.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import GRDB

struct NotificationsPreferences: Codable, FetchableRecord, PersistableRecord, DatabaseValueConvertible {
    var id: Int64 = 1
    var notificationsEnabled: Bool = true
    var notificationDisplayTime: Int = 5000
    var doNotDisturb: Bool = false
    var allProfiles: Bool = false

    static let databaseTableName = "NotificationsPreferences"
}
