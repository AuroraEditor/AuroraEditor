//
//  Project.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

@available(*, deprecated, renamed: "VersionControl", message: "This will be deprecated in favor of the new VersionControl Remote SDK APIs.")
/// Visibility Level
public enum VisibilityLevel: Int {

    /// Private
    case `private` = 0

    /// Internal
    case `internal` = 10

    /// Public
    case `public` = 20
}

/// Project
open class Project: Codable {

    /// Identifier
    public let id: Int

    /// Owner
    public let owner: GitlabUser

    /// Name
    open var name: String?

    /// Name With Namespace
    open var nameWithNamespace: String?

    /// Is Private
    open var isPrivate: Bool?

    /// Project Description
    open var projectDescription: String?

    /// SSH URL
    open var sshURL: URL?

    /// Clone URL
    open var cloneURL: URL?

    /// Web URL
    open var webURL: URL?

    /// Path
    open var path: String?

    /// Path With Namespace
    open var pathWithNamespace: String?

    /// Container Registery Enabled
    open var containerRegisteryEnabled: Bool?

    /// Default Branch
    open var defaultBranch: String?

    /// Tag List
    open var tagList: [String]?

    /// Is Archived
    open var isArchived: Bool?

    /// Issues Enabled
    open var issuesEnabled: Bool?

    /// Merge Requests Enabled
    open var mergeRequestsEnabled: Bool?

    /// Wiki Enabled
    open var wikiEnabled: Bool?

    /// Builds Enabled
    open var buildsEnabled: Bool?

    /// Snippets Enabled
    open var snippetsEnabled: Bool?

    /// Shared Runners Enabled
    open var sharedRunnersEnabled: Bool?

    /// Creator ID
    open var creatorID: Int?

    /// Namespace
    open var namespace: GitNameSpace?

    /// Avatar URL
    open var avatarURL: URL?

    /// Star Count
    open var starCount: Int?

    /// Forks Count
    open var forksCount: Int?

    /// Open Issues Count
    open var openIssuesCount: Int?

    /// Runners Token
    open var runnersToken: String?

    /// Public Builds
    open var publicBuilds: Bool?

    /// Created At
    open var createdAt: Date?

    /// Last Activity At
    open var lastActivityAt: Date?

    /// LFS Enabled
    open var lfsEnabled: Bool?

    /// Visibility Level
    open var visibilityLevel: String?

    /// Only Allow Merge If Build Succeeds
    open var onlyAllowMergeIfBuildSucceeds: Bool?

    /// Request Access Enabled
    open var requestAccessEnabled: Bool?

    /// Permissions
    open var permissions: String?

    /// Conding Keys
    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case name
        case nameWithNamespace = "name_with_namespace"
        case isPrivate = "public"
        case projectDescription = "description"
        case sshURL = "ssh_url_to_repo"
        case cloneURL = "http_url_to_repo"
        case webURL = "web_url"
        case path
        case pathWithNamespace = "path_with_namespace"
        case containerRegisteryEnabled = "container_registry_enabled"
        case defaultBranch = "default_branch"
        case tagList = "tag_list"
        case isArchived = "archived"
        case issuesEnabled = "issues_enabled"
        case mergeRequestsEnabled = "merge_requests_enabled"
        case wikiEnabled = "wiki_enabled"
        case buildsEnabled = "builds_enabled"
        case snippetsEnabled = "snippets_enabled"
        case sharedRunnersEnabled = "shared_runners_enabled"
        case publicBuilds = "public_builds"
        case creatorID = "creator_id"
        case namespace
        case avatarURL = "avatar_url"
        case starCount = "star_count"
        case forksCount = "forks_count"
        case openIssuesCount = "open_issues_count"
        case visibilityLevel = "visibility_level"
        case createdAt = "created_at"
        case lastActivityAt = "last_activity_at"
        case lfsEnabled = "lfs_enabled"
        case runnersToken = "runners_token"
        case onlyAllowMergeIfBuildSucceeds = "only_allow_merge_if_build_succeeds"
        case requestAccessEnabled = "request_access_enabled"
        case permissions = "permissions"
    }
}
