//
//  Gist.swift
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
/// Gist class
open class Gist: Codable {

    /// Gist Identifier
    open private(set) var id: String?

    /// Gist URL
    open var url: URL?

    /// Gist Forks URL
    open var forksURL: URL?

    /// Gist Commits URL
    open var commitsURL: URL?

    /// Gist Git Push URL
    open var gitPushURL: URL?

    /// Gist Git Pull URL
    open var gitPullURL: URL?

    /// Gist Comments URL
    open var commentsURL: URL?

    /// Gist HTML URL
    open var htmlURL: URL?

    /// Gist Files
    open var files: Files

    /// Gist Public
    open var publicGist: Bool?

    /// Gist Created At
    open var createdAt: Date?

    /// Gist Updated At
    open var updatedAt: Date?

    /// Gist Description
    open var description: String?

    /// Gist Comments
    open var comments: Int?

    /// Gist User
    open var user: GithubUser?

    /// Gist Owner
    open var owner: GithubUser?

    /// Coding keys
    enum CodingKeys: String, CodingKey {
        case id
        case url
        case forksURL = "forks_url"
        case commitsURL = "commits_url"
        case gitPushURL = "git_pull_url"
        case gitPullURL = "git_push_url"
        case commentsURL = "comments_url"
        case htmlURL = "html_url"
        case files
        case publicGist = "public"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case description
        case comments
        case user
        case owner
    }
}

public extension GithubAccount {

    /// Fetches the gists of the authenticated user.
    ///
    /// - Parameters:
    ///     - session: The GitURLSession to use for the request. Defaults to URLSession.shared.
    ///     - page: The current page for gist pagination. Defaults to 1.
    ///     - perPage: The number of gists per page. Defaults to 100.
    ///     - completion: The callback for the outcome of the fetch.
    ///
    /// - Returns: The URLSessionTask for the fetch.
    @discardableResult
    func myGists(
        _ session: GitURLSession = URLSession.shared,
        page: String = "1",
        perPage: String = "100",
        completion: @escaping (
            _ response: Result<[Gist], Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = GistRouter.readAuthenticatedGists(configuration, page, perPage)

        return router.load(
            session,
            dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
            expectedResultType: [Gist].self) { gists, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if let gists = gists {
                    completion(.success(gists))
                }
            }
        }
    }

    /// Fetches the gists of the specified user
    /// 
    /// - Parameters:
    ///  - session: GitURLSession, defaults to URLSession.sharedSession()
    ///  - owner: The username who owns the gists.
    ///  - page: Current page for gist pagination. `1` by default.
    ///  - perPage: Number of gists per page. `100` by default.
    ///  - completion: Callback for the outcome of the fetch.
    /// 
    /// - Returns: URLSessionTask
    @discardableResult
    func gists(
        _ session: GitURLSession = URLSession.shared,
        owner: String,
        page: String = "1",
        perPage: String = "100",
        completion: @escaping (
            _ response: Result<[Gist], Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = GistRouter.readGists(configuration, owner, page, perPage)

        return router.load(
            session,
            dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
            expectedResultType: [Gist].self) { gists, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if let gists = gists {
                    completion(.success(gists))
                }
            }
        }
    }

    /// Fetches an gist
    ///
    /// - parameter session: GitURLSession, defaults to URLSession.sharedSession()
    /// - parameter id: The id of the gist.
    /// - parameter completion: Callback for the outcome of the fetch.
    ///
    /// - returns: URLSessionTask
    @discardableResult
    func gist(
        _ session: GitURLSession = URLSession.shared,
        id: String,
        completion: @escaping (
            _ response: Result<Gist, Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = GistRouter.readGist(configuration, id)

        return router.load(
            session,
            dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
            expectedResultType: Gist.self) { gist, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if let gist = gist {
                    completion(.success(gist))
                }
            }
        }
    }

    /// Creates an gist with a single file.
    /// 
    /// - Parameters:
    ///   - session: GitURLSession, defaults to URLSession.sharedSession()
    ///   - description: The description of the gist.
    ///   - filename: The name of the file in the gist.
    ///   - fileContent: The content of the file in the gist.
    ///   - publicAccess: The public/private visability of the gist.
    ///   - completion: Callback for the gist that is created.
    /// 
    /// - Returns: URLSessionTask
    @discardableResult
    func postGistFile(_ session: GitURLSession = URLSession.shared,
                      description: String,
                      filename: String,
                      fileContent: String,
                      publicAccess: Bool,
                      completion: @escaping (
                        _ response: Result<Gist, Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = GistRouter.postGistFile(configuration, description, filename, fileContent, publicAccess)
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .formatted(Time.rfc3339DateFormatter)

        return router.post(
            session,
            decoder: decoder,
            expectedResultType: Gist.self) { gist, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if let gist = gist {
                    completion(.success(gist))
                }
            }
        }
    }

    /// Edits an gist with a single file.
    ///
    /// - parameter session: GitURLSession, defaults to URLSession.sharedSession()
    /// - parameter id: The of the gist to update.
    /// - parameter description: The description of the gist.
    /// - parameter filename: The name of the file in the gist.
    /// - parameter fileContent: The content of the file in the gist.
    /// - parameter completion: Callback for the gist that is created.
    ///
    /// - returns: URLSessionTask
    @discardableResult
    func patchGistFile(_ session: GitURLSession = URLSession.shared,
                       id: String,
                       description: String,
                       filename: String,
                       fileContent: String,
                       completion: @escaping (
                        _ response: Result<Gist, Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = GistRouter.patchGistFile(configuration, id, description, filename, fileContent)
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .formatted(Time.rfc3339DateFormatter)

        return router.post(
            session,
            decoder: decoder,
            expectedResultType: Gist.self) { gist, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if let gist = gist {
                    completion(.success(gist))
                }
            }
        }
    }
}
