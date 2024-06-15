//
//  GitlabUser.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Gitlab User
open class GitlabUser: Codable {

    /// Identifier
    open var id: Int

    /// Username
    open var username: String?

    /// State
    open var state: String?

    /// Avatar URL
    open var avatarURL: URL?

    /// Web URL
    open var webURL: URL?

    /// Created At
    open var createdAt: Date?

    /// Is Admin
    open var isAdmin: Bool?

    /// Name
    open var name: String?

    /// Last Sign In At
    open var lastSignInAt: Date?

    /// Confirmed At
    open var confirmedAt: Date?

    /// Email
    open var email: String?

    /// Projects Limit
    open var projectsLimit: Int?

    /// Current Sign In At
    open var currentSignInAt: Date?

    /// Can Create Group
    open var canCreateGroup: Bool?

    /// Can Create Project
    open var canCreateProject: Bool?

    /// Two Factor Enabled
    open var twoFactorEnabled: Bool?

    /// External
    open var external: Bool?

    /// Initialize Gitlab User
    /// 
    /// - Parameter json: JSON
    /// 
    /// - Returns: Gitlab User
    public init(_ json: [String: Any]) {
        if let id = json["id"] as? Int {
            name = json["name"] as? String
            username = json["username"] as? String
            self.id = id
            state = json["state"] as? String
            if let urlString = json["avatar_url"] as? String, let url = URL(string: urlString) {
                avatarURL = url
            }
            if let urlString = json["web_url"] as? String, let url = URL(string: urlString) {
                webURL = url
            }
            createdAt = Time.rfc3339Date(json["created_at"] as? String)
            isAdmin = json["is_admin"] as? Bool
            lastSignInAt = Time.rfc3339Date(json["last_sign_in_at"] as? String)
            confirmedAt = Time.rfc3339Date(json["confirmed_at"] as? String)
            email = json["email"] as? String
            projectsLimit = json["projects_limit"] as? Int
            currentSignInAt = Time.rfc3339Date(json["current_sign_in_at"] as? String)
            canCreateGroup = json["can_create_group"] as? Bool
            canCreateProject = json["can_create_project"] as? Bool
            twoFactorEnabled = json["two_factor_enabled"] as? Bool
            external = json["external"] as? Bool
        } else {
            id = -1
        }
    }
}

public extension GitlabAccount {

    /// Fetches the currently logged in user
    /// 
    /// - parameter completion: Callback for the outcome of the fetch.
    /// 
    /// - Returns: URLSessionDataTaskProtocol
    @discardableResult
    func me(
        _ session: GitURLSession = URLSession.shared,
        completion: @escaping (_ response: Result<GitlabUser, Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = UserRouter.readAuthenticatedUser(self.configuration)

            return router.load(session,
                               dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                               expectedResultType: GitlabUser.self) { data, error in

                if let error = error {
                    completion(Result.failure(error))
                }

                if let data = data {
                    completion(Result.success(data))
                }
            }
    }
}
