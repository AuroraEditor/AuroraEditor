//
//  Namespace.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

@available(*, deprecated, renamed: "VersionControl", message: "This will be deprecated in favor of the new VersionControl Remote SDK APIs.")
/// Git Name Space
open class GitNameSpace: Codable {

    /// Identifier
    open var id: Int?

    /// Name
    open var name: String?

    /// Path
    open var path: String?

    /// Owner ID
    open var ownerID: Int?

    /// Created At
    open var createdAt: Date?

    /// Updated At
    open var updatedAt: Date?

    /// Namespace Description
    open var namespaceDescription: String?

    /// Avatar
    open var avatar: AvatarURL?

    /// Share With Group Locked
    open var shareWithGroupLocked: Bool?

    /// Visibility Level
    open var visibilityLevel: Int?

    /// Request Access Enabled
    open var requestAccessEnabled: Bool?

    /// Deleted At
    open var deletedAt: Date?

    /// LFS Enabled
    open var lfsEnabled: Bool?

    /// Initialize Git Name Space
    /// 
    /// - Parameter json: JSON
    /// 
    /// - Returns: Git Name Space
    public init(_ json: [String: AnyObject]) {
        if let id = json["id"] as? Int {
            self.id = id
            name = json["name"] as? String
            path = json["path"] as? String
            ownerID = json["owner_id"] as? Int
            createdAt = Time.rfc3339Date(json["created_at"] as? String)
            updatedAt = Time.rfc3339Date(json["updated_at"] as? String)
            namespaceDescription = json["description"] as? String
            avatar = AvatarURL(json["avatar"] as? [String: AnyObject] ?? [:])
            shareWithGroupLocked = json["share_with_group_lock"] as? Bool
            visibilityLevel = json["visibility_level"] as? Int
            requestAccessEnabled = json["request_access_enabled"] as? Bool
            deletedAt = Time.rfc3339Date(json["deleted_at"] as? String)
            lfsEnabled = json["lfs_enabled"] as? Bool
        }
    }
}
