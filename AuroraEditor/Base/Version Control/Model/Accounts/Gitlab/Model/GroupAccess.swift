//
//  GroupAccess.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Group Access
open class GroupAccess: Codable {

    /// Access Level
    open var accessLevel: Int?

    /// Notification Level
    open var notificationLevel: Int?

    /// Initialize Group Access
    /// 
    /// - Parameter json: JSON
    /// 
    /// - Returns: Group Access
    public init(_ json: [String: AnyObject]) {
        accessLevel = json["access_level"] as? Int
        notificationLevel = json["notification_level"] as? Int
    }
}
