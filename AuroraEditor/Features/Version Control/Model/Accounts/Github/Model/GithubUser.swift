//
//  GithubUser.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@available(*, deprecated, renamed: "VersionControl", message: "This will be deprecated in favor of the new VersionControl Remote SDK APIs.")
/// Github User
open class GithubUser: Codable {

    /// User Identifier
    open internal(set) var id: Int = -1

    /// User Login
    open var login: String?

    /// User Avatar URL
    open var avatarURL: String?

    /// User Gravatar ID
    open var gravatarID: String?

    /// User Type
    open var type: String?

    /// User Name
    open var name: String?

    /// User Company
    open var company: String?

    /// User Email
    open var email: String?

    /// User Number of Public Repos
    open var numberOfPublicRepos: Int?

    /// User Number of Public Gists
    open var numberOfPublicGists: Int?

    /// User Number of Private Repos
    open var numberOfPrivateRepos: Int?

    /// User Node ID
    open var nodeID: String?

    /// User URL
    open var url: String?

    /// User HTML URL
    open var htmlURL: String?

    /// User Gists URL
    open var gistsURL: String?

    /// User Starred URL
    open var starredURL: String?

    /// User Subscriptions URL
    open var subscriptionsURL: String?

    /// User Repos URL
    open var reposURL: String?

    /// User Events URL
    open var eventsURL: String?

    /// User Received Events URL
    open var receivedEventsURL: String?

    /// User Created At
    open var createdAt: Date?

    /// User Updated At
    open var updatedAt: Date?

    /// User Number of Private Gists
    open var numberOfPrivateGists: Int?

    /// User Number of Own Private Repos
    open var numberOfOwnPrivateRepos: Int?

    /// User Two Factor Authentication Enabled
    open var twoFactorAuthenticationEnabled: Bool?

    /// Coding keys
    enum CodingKeys: String, CodingKey {
        case id
        case login
        case avatarURL = "avatar_url"
        case gravatarID = "gravatar_id"
        case type
        case name
        case company
        case email
        case numberOfPublicRepos = "public_repos"
        case numberOfPublicGists = "public_gists"
        case numberOfPrivateRepos = "total_private_repos"
        case nodeID = "node_id"
        case url
        case htmlURL = "html_url"
        case gistsURL = "gists_url"
        case starredURL = "starred_url"
        case subscriptionsURL = "subscriptions_url"
        case reposURL = "repos_url"
        case eventsURL = "events_url"
        case receivedEventsURL = "received_events_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case numberOfPrivateGists = "private_gists"
        case numberOfOwnPrivateRepos = "owned_private_repos"
        case twoFactorAuthenticationEnabled = "two_factor_authentication"
    }
}

public extension GithubAccount {
    /// Fetches a user or organization
    /// 
    /// - parameter session: GitURLSession, defaults to URLSession.shared
    /// - parameter name: The name of the user or organization.
    /// - parameter completion: Callback for the outcome of the fetch.
    ///
    /// - Returns: URLSessionDataTaskProtocol
    @discardableResult
    func user(
        _ session: GitURLSession = URLSession.shared,
        name: String,
        completion: @escaping (_ response: Result<GithubUser, Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = GithubUserRouter.readUser(name, configuration)

        return router.load(
            session,
            dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
            expectedResultType: GithubUser.self) { user, error in
            if let error = error {
                completion(.failure(error))
            } else {
                if let user = user {
                    completion(.success(user))
                }
            }
        }
    }

    /// Fetches the authenticated user
    /// 
    /// - parameter session: GitURLSession, defaults to URLSession.shared
    /// - parameter completion: Callback for the outcome of the fetch.
    ///
    /// - Returns: URLSessionDataTaskProtocol
    @discardableResult
    func me(
        _ session: GitURLSession = URLSession.shared,
        completion: @escaping (_ response: Result<GithubUser, Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = GithubUserRouter.readAuthenticatedUser(configuration)

        return router.load(
            session,
            dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
            expectedResultType: GithubUser.self) { user, error in
            if let error = error {
                completion(.failure(error))
            } else {
                if let user = user {
                    completion(.success(user))
                }
            }
        }
    }
}
