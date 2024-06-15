//
//  Repositories.swift
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
/// Github Repositories
open class GithubRepositories: Codable {

    /// Repository Identifier
    open private(set) var id: Int = -1

    /// Repository Owner
    open private(set) var owner = GithubUser()

    /// Repository Name
    open var name: String?

    /// Repository Full Name
    open var fullName: String?

    /// Repository Private
    open private(set) var isPrivate: Bool = false

    /// Repository Description
    open var repositoryDescription: String?

    /// Repository Fork
    open private(set) var isFork: Bool = false

    /// Repository Git URL
    open var gitURL: String?

    /// Repository SSH URL
    open var sshURL: String?

    /// Repository Clone URL
    open var cloneURL: String?

    /// Repository HTML URL
    open var htmlURL: String?

    /// Repository Size
    open private(set) var size: Int? = -1

    /// Repository Last Push
    open var lastPush: Date?

    /// Repository Stargazers Count
    open var stargazersCount: Int?

    /// Coding keys
    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case name
        case fullName = "full_name"
        case isPrivate = "private"
        case repositoryDescription = "description"
        case isFork = "fork"
        case gitURL = "git_url"
        case sshURL = "ssh_url"
        case cloneURL = "clone_url"
        case htmlURL = "html_url"
        case size
        case lastPush = "pushed_at"
        case stargazersCount = "stargazers_count"
    }
}

public extension GithubAccount {

    /// Fetches the Repositories for a user or organization
    /// 
    /// - parameter session: GitURLSession, defaults to URLSession.shared
    /// - parameter owner: The user or organization that owns the repositories. If `nil`,
    ///                    fetches repositories for the authenticated user.
    /// - parameter page: Current page for repository pagination. `1` by default.
    /// - parameter perPage: Number of repositories per page. `100` by default.
    /// - parameter completion: Callback for the outcome of the fetch.
    /// 
    /// - returns: URLSessionDataTaskProtocol
    @discardableResult
    func repositories(_ session: GitURLSession = URLSession.shared,
                      owner: String? = nil,
                      page: String = "1",
                      perPage: String = "100",
                      completion: @escaping (
                        _ response: Result<[GithubRepositories], Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = (owner != nil)
            ? GithubRepositoryRouter.readRepositories(configuration, owner!, page, perPage)
            : GithubRepositoryRouter.readAuthenticatedRepositories(configuration, page, perPage)

        return router.load(
            session,
            dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
            expectedResultType: [GithubRepositories].self) { repos, error in
            if let error = error {
                completion(.failure(error))
            }

            if let repos = repos {
                completion(.success(repos))
            }
        }
    }

    /// Fetches a repository for a user or organization
    ///
    /// - parameter session: GitURLSession, defaults to URLSession.shared
    /// - parameter owner: The user or organization that owns the repositories.
    /// - parameter name: The name of the repository to fetch.
    /// - parameter completion: Callback for the outcome of the fetch.
    ///
    /// - returns: URLSessionDataTaskProtocol
    @discardableResult
    func repository(_ session: GitURLSession = URLSession.shared,
                    owner: String,
                    name: String,
                    completion: @escaping (
                    _ response: Result<GithubRepositories, Error>
                    ) -> Void) -> URLSessionDataTaskProtocol? {
        let router = GithubRepositoryRouter.readRepository(configuration, owner, name)

        return router.load(
            session,
            dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
            expectedResultType: GithubRepositories.self) { repo, error in
            if let error = error {
                completion(.failure(error))
            } else {
                if let repo = repo {
                    completion(.success(repo))
                }
            }
        }
    }
}
