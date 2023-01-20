//
//  ProjectAccess.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

open class ProjectAccess: Codable {
    open var accessLevel: Int?
    open var notificationLevel: Int?

    public init(_ json: [String: AnyObject]) {
        accessLevel = json["access_level"] as? Int
        notificationLevel = json["notification_level"] as? Int
    }
}
