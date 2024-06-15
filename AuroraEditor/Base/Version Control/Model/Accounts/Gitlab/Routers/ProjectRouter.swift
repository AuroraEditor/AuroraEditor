//
//  ProjectRouter.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Visibility
public enum Visibility: String {

    /// Public
    case visbilityPublic = "public"

    /// Internal
    case visibilityInternal = "interal"

    /// Private
    case visibilityPrivate = "private"

    /// All
    case all = ""
}

/// Order By
public enum OrderBy: String {

    /// Identifier
    case id = "id"

    /// Name
    case name = "name"

    /// Path
    case path = "path"

    /// Created Date
    case creationDate = "created_at"

    /// Update Date
    case updateDate = "updated_at"

    /// Last Activity Date
    case lastActvityDate = "last_activity_at"
}

/// Sort
public enum Sort: String {

    /// Ascending
    case ascending = "asc"

    /// Descending
    case descending = "desc"
}

/// Project Router
enum ProjectRouter: Router {

    /// Read Authenticated Projects
    /// 
    /// - Parameter configuration: Git Configuration
    /// - Parameter page: Page
    /// - Parameter perPage: Per Page
    /// - Parameter archived: Archived
    /// - Parameter visibility: Visibility
    /// - Parameter orderBy: Order By
    /// - Parameter sort: Sort
    /// - Parameter search: Search
    /// - Parameter simple: Simple
    case readAuthenticatedProjects(
        configuration: GitConfiguration,
        page: String,
        perPage: String,
        archived: Bool,
        visibility: Visibility,
        orderBy: OrderBy,
        sort: Sort,
        search: String,
        simple: Bool)

    /// Read Visible Projects
    /// 
    /// - Parameter configuration: Git Configuration
    /// - Parameter page: Page
    /// - Parameter perPage: Per Page
    /// - Parameter archived: Archived
    /// - Parameter visibility: Visibility
    /// - Parameter orderBy: Order By
    /// - Parameter sort: Sort
    /// - Parameter search: Search
    /// - Parameter simple: Simple
    case readVisibleProjects(
        configuration: GitConfiguration,
        page: String,
        perPage: String,
        archived: Bool,
        visibility: Visibility,
        orderBy: OrderBy,
        sort: Sort,
        search: String,
        simple: Bool)

    /// Read Owned Projects
    /// 
    /// - Parameter configuration: Git Configuration
    /// - Parameter page: Page
    /// - Parameter perPage: Per Page
    /// - Parameter archived: Archived
    /// - Parameter visibility: Visibility
    /// - Parameter orderBy: Order By
    /// - Parameter sort: Sort
    /// - Parameter search: Search
    /// - Parameter simple: Simple
    case readOwnedProjects(
        configuration: GitConfiguration,
        page: String,
        perPage: String,
        archived: Bool,
        visibility: Visibility,
        orderBy: OrderBy,
        sort: Sort,
        search: String,
        simple: Bool)

    /// Read Starred Projects
    /// 
    /// - Parameter configuration: Git Configuration
    /// - Parameter page: Page
    /// - Parameter perPage: Per Page
    /// - Parameter archived: Archived
    /// - Parameter visibility: Visibility
    /// - Parameter orderBy: Order By
    /// - Parameter sort: Sort
    /// - Parameter search: Search
    /// - Parameter simple: Simple
    case readStarredProjects(
        configuration: GitConfiguration,
        page: String,
        perPage: String,
        archived: Bool,
        visibility: Visibility,
        orderBy: OrderBy,
        sort: Sort,
        search: String,
        simple: Bool)

    /// Read All Projects
    /// 
    /// - Parameter configuration: Git Configuration
    /// - Parameter page: Page
    /// - Parameter perPage: Per Page
    /// - Parameter archived: Archived
    /// - Parameter visibility: Visibility
    /// - Parameter orderBy: Order By
    /// - Parameter sort: Sort
    /// - Parameter search: Search
    /// - Parameter simple: Simple
    case readAllProjects(
        configuration: GitConfiguration,
        page: String,
        perPage: String,
        archived: Bool,
        visibility: Visibility,
        orderBy: OrderBy,
        sort: Sort,
        search: String,
        simple: Bool)

    /// Read Single Project
    /// 
    /// - Parameter configuration: Git Configuration
    /// - Parameter id: Identifier
    case readSingleProject(configuration: GitConfiguration, id: String)

    /// Read Project Events
    /// 
    /// - Parameter configuration: Git Configuration
    /// - Parameter id: Identifier
    /// - Parameter page: Page
    /// - Parameter perPage: Per Page
    case readProjectEvents(configuration: GitConfiguration, id: String, page: String, perPage: String)

    /// Read Project Hooks
    /// 
    /// - Parameter configuration: Git Configuration
    /// - Parameter id: Identifier
    case readProjectHooks(configuration: GitConfiguration, id: String)

    /// Read Project Hook
    /// 
    /// - Parameter configuration: Git Configuration
    /// - Parameter id: Identifier
    /// - Parameter hookId: Hook Identifier
    case readProjectHook(configuration: GitConfiguration, id: String, hookId: String)

    /// Configuration
    var configuration: GitConfiguration? {
        switch self {
        case .readAuthenticatedProjects(let config, _, _, _, _, _, _, _, _): return config
        case .readVisibleProjects(let config, _, _, _, _, _, _, _, _): return config
        case .readOwnedProjects(let config, _, _, _, _, _, _, _, _): return config
        case .readStarredProjects(let config, _, _, _, _, _, _, _, _): return config
        case .readAllProjects(let config, _, _, _, _, _, _, _, _): return config
        case .readSingleProject(let config, _): return config
        case .readProjectEvents(let config, _, _, _): return config
        case .readProjectHooks(let config, _): return config
        case .readProjectHook(let config, _, _): return config
        }
    }

    /// HTTP Method
    var method: HTTPMethod {
        .GET
    }

    /// HTTP Encoding
    var encoding: HTTPEncoding {
        .url
    }

    /// Parameters
    var params: [String: Any] {
        switch self {
        case let .readAuthenticatedProjects(
            _,
            page,
            perPage,
            archived,
            visibility,
            orderBy,
            sort,
            search,
            simple):
            return [
                "page": page,
                "per_page": perPage,
                "archived": String(archived),
                "visibility": visibility,
                "order_by": orderBy,
                "sort": sort,
                "search": search,
                "simple": String(simple)]
        case let .readVisibleProjects(
            _,
            page,
            perPage,
            archived,
            visibility,
            orderBy,
            sort,
            search,
            simple):
            return [
                "page": page,
                "per_page": perPage,
                "archived": String(archived),
                "visibility": visibility,
                "order_by": orderBy,
                "sort": sort,
                "search": search,
                "simple": String(simple)]
        case let .readOwnedProjects(
            _,
            page,
            perPage,
            archived,
            visibility,
            orderBy,
            sort,
            search,
            simple):
            return [
                "page": page,
                "per_page": perPage,
                "archived": String(archived),
                "visibility": visibility,
                "order_by": orderBy,
                "sort": sort,
                "search": search,
                "simple": String(simple)]
        case let .readStarredProjects(
            _,
            page,
            perPage,
            archived,
            visibility,
            orderBy,
            sort,
            search,
            simple):
            return [
                "page": page,
                "per_page": perPage,
                "archived": String(archived),
                "visibility": visibility,
                "order_by": orderBy,
                "sort": sort,
                "search": search,
                "simple": String(simple)]
        case let .readAllProjects(
            _,
            page,
            perPage,
            archived,
            visibility,
            orderBy,
            sort,
            search,
            simple):
            return [
                "page": page,
                "per_page": perPage,
                "archived": String(archived),
                "visibility": visibility,
                "order_by": orderBy,
                "sort": sort,
                "search": search,
                "simple": String(simple)]
        case .readSingleProject:
            return [:]
        case let .readProjectEvents(_, _, page, perPage):
            return ["per_page": perPage, "page": page]
        case .readProjectHooks:
            return [:]
        case .readProjectHook:
            return [:]
        }
    }

    /// Path
    var path: String {
        switch self {
        case .readAuthenticatedProjects:
            return "projects"
        case .readVisibleProjects:
            return "projects/visible"
        case .readOwnedProjects:
            return "projects/owned"
        case .readStarredProjects:
            return "projects/starred"
        case .readAllProjects:
            return "projects/all"
        case let .readSingleProject(_, id):
            return "projects/\(id)"
        case let .readProjectEvents(_, id, _, _):
            return "projects/\(id)/events"
        case let .readProjectHooks(_, id):
            return "projects/\(id)/hooks"
        case let .readProjectHook(_, id, hookId):
            return "projects/\(id)/hooks/\(hookId)"
        }
    }
}
