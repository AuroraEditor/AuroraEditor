//
//  ProjectHook.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Project Hook
open class ProjectHook: Codable {

    /// Identifier
    open var id: Int?

    /// URL
    open var url: URL?

    /// Project ID
    open var projectID: Int?

    /// Push Events
    open var pushEvents: Bool?

    /// Issues Events
    open var issuesEvents: Bool?

    /// Merge Requests Events
    open var mergeRequestsEvents: Bool?

    /// Tag Push Events
    open var tagPushEvents: Bool?

    /// Note Events
    open var noteEvents: Bool?

    /// Build Events
    open var buildEvents: Bool?

    /// Pipeline Events
    open var pipelineEvents: Bool?

    /// Wiki Page Events
    open var wikiPageEvents: Bool?

    /// Enable SSL Verification
    open var enableSSLVerification: Bool?

    /// Created At
    open var createdAt: Date?

    /// Coding Keys
    enum CodingKeys: String, CodingKey {
        case id
        case url
        case projectID = "project_id"
        case pushEvents = "push_events"
        case issuesEvents = "issues_events"
        case mergeRequestsEvents = "merge_requests_events"
        case tagPushEvents = "tag_push_events"
        case noteEvents = "note_events"
        case buildEvents = "build_events"
        case pipelineEvents = "pipeline_events"
        case wikiPageEvents = "wiki_page_events"
        case enableSSLVerification = "enable_ssl_verification"
        case createdAt = "created_at"
    }
}

public extension GitlabAccount {

    /// Get a list of project hooks.
    /// 
    /// - parameter id: The ID of the project or namespace/project name.
    /// Make sure that the namespace/project-name is URL-encoded, eg. "%2F" for "/".
    /// - parameter completion: Callback for the outcome of the fetch.
    ///
    /// - returns: The data task that was created.
    func projectHooks(_ session: GitURLSession = URLSession.shared,
                      id: String,
                      completion: @escaping (
                        _ response: Result<ProjectHook, Error>) -> Void) -> URLSessionDataTaskProtocol? {

                            let router = ProjectRouter.readProjectHooks(configuration: configuration, id: id)

                            return router.load(session,
                                               dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                                               expectedResultType: ProjectHook.self) { json, error in

                                if let error = error {
                                    completion(Result.failure(error))
                                }

                                if let json = json {
                                    completion(Result.success(json))
                                }
                            }
                        }

    /// Get a specific hook from a project.
    /// 
    /// - parameter id: The ID of the project or namespace/project name.
    /// Make sure that the namespace/project-name is URL-encoded, eg. "%2F" for "/".
    /// - parameter hookId: The ID of the hook in the project
    /// (you can get the ID of a hook by searching for it with the **allProjectHooks** request).
    /// - parameter completion: Callback for the outcome of the fetch.
    /// 
    /// - returns: The data task that was created.
    func projectHook(_ session: GitURLSession = URLSession.shared,
                     id: String,
                     hookId: String,
                     completion: @escaping (
                        _ response: Result<ProjectHook, Error>) -> Void) -> URLSessionDataTaskProtocol? {

                            let router = ProjectRouter.readProjectHook(configuration: configuration,
                                                                       id: id,
                                                                       hookId: hookId)

                            return router.load(session,
                                               dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                                               expectedResultType: ProjectHook.self) { json, error in

                                if let error = error {
                                    completion(Result.failure(error))
                                }

                                if let json = json {
                                    completion(Result.success(json))
                                }
                            }
                        }
}
