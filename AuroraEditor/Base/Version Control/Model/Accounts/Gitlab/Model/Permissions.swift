//
//  Permissions.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Permissions
open class Permissions: Codable {

    /// Project Access
    open var projectAccess: ProjectAccess?

    /// Group Access
    open var groupAccess: GroupAccess?

    /// Initialize Permissions
    /// 
    /// - Parameter json: JSON
    /// 
    /// - Returns: Permissions
    public init(_ json: [String: AnyObject]) {
        projectAccess = ProjectAccess(json["project_access"] as? [String: AnyObject] ?? [:])
        groupAccess = GroupAccess(json["group_access"] as? [String: AnyObject] ?? [:])
    }
}
