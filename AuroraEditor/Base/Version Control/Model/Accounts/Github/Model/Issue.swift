//
//  Issue.swift
//  Aurora Editor
//
//  Created by Nanshi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@available(*, deprecated, renamed: "VersionControl", message: "This will be deprecated in favor of the new VersionControl Remote SDK APIs.")
/// Github Issue
open class Issue: Codable {

    /// Issue Identifier
    open private(set) var id: Int = -1

    /// Issue URL
    open var url: URL?

    /// Issue Repository URL
    open var repositoryURL: URL?

    /// Issue Labels URL
    @available(*, deprecated)
    open var labelsURL: URL?

    /// Issue Comments URL
    open var commentsURL: URL?

    /// Issue Events URL
    open var eventsURL: URL?

    /// Issue HTML URL
    open var htmlURL: URL?

    /// Issue Number
    open var number: Int

    /// Issue State
    open var state: Openness?

    /// Issue Title
    open var title: String?

    /// Issue Body
    open var body: String?

    /// Issue User
    open var user: GithubUser?

    /// Issue Assignee
    open var assignee: GithubUser?

    /// Issue Locked
    open var locked: Bool?

    /// Issue Comments
    open var comments: Int?

    /// Issue Closed At
    open var closedAt: Date?

    /// Issue Created At
    open var createdAt: Date?

    /// Issue Updated At
    open var updatedAt: Date?

    /// Issue Closed By
    open var closedBy: GithubUser?

    /// Coding keys
    enum CodingKeys: String, CodingKey {
        case id
        case url
        case repositoryURL = "repository_url"
        case commentsURL = "comments_url"
        case eventsURL = "events_url"
        case htmlURL = "html_url"
        case number
        case state
        case title
        case body
        case user
        case assignee
        case locked
        case comments
        case closedAt = "closed_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case closedBy = "closed_by"
    }
}

public extension GithubAccount {
    /// Fetches the issues of the authenticated user
    /// 
    /// - parameter session: GitURLSession, defaults to URLSession.sharedSession()
    /// - parameter state: Issue state. Defaults to open if not specified.
    /// - parameter page: Current page for issue pagination. `1` by default.
    /// - parameter perPage: Number of issues per page. `100` by default.
    /// - parameter completion: Callback for the outcome of the fetch.
    /// 
    /// - returns: URLSessionDataTaskProtocol
    @discardableResult
    func myIssues(_ session: GitURLSession = URLSession.shared,
                  state: Openness = .open,
                  page: String = "1",
                  perPage: String = "100",
                  completion: @escaping (
                    _ response: Result<[Issue], Error>) -> Void) -> URLSessionDataTaskProtocol? {
        let router = IssueRouter.readAuthenticatedIssues(configuration, page, perPage, state)

        return router.load(
            session,
            dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
            expectedResultType: [Issue].self) { issues, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if let issues = issues {
                    completion(.success(issues))
                }
            }
        }
    }

    /// Fetches an issue in a repository
    /// 
    /// - parameter session: GitURLSession, defaults to URLSession.sharedSession()
    /// - parameter owner: The user or organization that owns the repository.
    /// - parameter repository: The name of the repository.
    /// - parameter number: The number of the issue.
    /// - parameter completion: Callback for the outcome of the fetch.
    ///
    /// - returns: URLSessionDataTaskProtocol
    @discardableResult
    func issue(_ session: GitURLSession = URLSession.shared,
               owner: String,
               repository: String,
               number: Int,
               completion: @escaping (
                _ response: Result<Issue, Error>
               ) -> Void) -> URLSessionDataTaskProtocol? {
        let router = IssueRouter.readIssue(configuration, owner, repository, number)

        return router.load(
            session,
            dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
            expectedResultType: Issue.self) { issue, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if let issue = issue {
                    completion(.success(issue))
                }
            }
        }
    }

    /// Fetches all issues in a repository
    /// 
    /// - parameter session: GitURLSession, defaults to URLSession.sharedSession()
    /// - parameter owner: The user or organization that owns the repository.
    /// - parameter repository: The name of the repository.
    /// - parameter state: Issue state. Defaults to open if not specified.
    /// - parameter page: Current page for issue pagination. `1` by default.
    /// - parameter perPage: Number of issues per page. `100` by default.
    /// - parameter completion: Callback for the outcome of the fetch.
    ///
    /// - returns: URLSessionDataTaskProtocol
    @discardableResult
    func issues(_ session: GitURLSession = URLSession.shared,
                owner: String,
                repository: String,
                state: Openness = .open,
                page: String = "1",
                perPage: String = "100",
                completion: @escaping (
                    _ response: Result<[Issue], Error>) -> Void) -> URLSessionDataTaskProtocol? {
        let router = IssueRouter.readIssues(configuration, owner, repository, page, perPage, state)

        return router.load(
            session,
            dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
            expectedResultType: [Issue].self) { issues, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if let issues = issues {
                    completion(.success(issues))
                }
            }
        }
    }

    /// Creates an issue in a repository.
    /// 
    /// - parameter session: GitURLSession, defaults to URLSession.sharedSession()
    /// - parameter owner: The user or organization that owns the repository.
    /// - parameter repository: The name of the repository.
    /// - parameter title: The title of the issue.
    /// - parameter body: The body text of the issue in GitHub-flavored Markdown format.
    /// - parameter assignee: The name of the user to assign the issue to.
    ///                       This parameter is ignored if the user lacks push access to the repository.
    /// - parameter labels: An array of label names to add to the issue. If the labels do not exist,
    ///                     GitHub will create them automatically.
    ///                     This parameter is ignored if the user lacks push access to the repository.
    /// - parameter completion: Callback for the issue that is created.
    ///
    /// - returns: URLSessionDataTaskProtocol
    @discardableResult
    func postIssue(_ session: GitURLSession = URLSession.shared,
                   owner: String,
                   repository: String,
                   title: String,
                   body: String? = nil,
                   assignee: String? = nil,
                   labels: [String] = [],
                   completion: @escaping (
                    _ response: Result<Issue, Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = IssueRouter.postIssue(configuration, owner, repository, title, body, assignee, labels)
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .formatted(Time.rfc3339DateFormatter)

        return router.post(
            session,
            decoder: decoder,
            expectedResultType: Issue.self) { issue, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if let issue = issue {
                    completion(.success(issue))
                }
            }
        }
    }

    /// Edits an issue in a repository.
    /// 
    /// - parameter session: GitURLSession, defaults to URLSession.sharedSession()
    /// - parameter owner: The user or organization that owns the repository.
    /// - parameter repository: The name of the repository.
    /// - parameter number: The number of the issue.
    /// - parameter title: The title of the issue.
    /// - parameter body: The body text of the issue in GitHub-flavored Markdown format.
    /// - parameter assignee: The name of the user to assign the issue to.
    ///                       This parameter is ignored if the user lacks push access to the repository.
    /// - parameter state: Whether the issue is open or closed.
    /// - parameter completion: Callback for the issue that is created.
    ///
    /// - returns: URLSessionDataTaskProtocol
    @discardableResult
    func patchIssue(_ session: GitURLSession = URLSession.shared,
                    owner: String,
                    repository: String,
                    number: Int,
                    title: String? = nil,
                    body: String? = nil,
                    assignee: String? = nil,
                    state: Openness? = nil,
                    completion: @escaping (
                        _ response: Result<Issue, Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = IssueRouter.patchIssue(configuration, owner, repository, number, title, body, assignee, state)

        return router.post(
            session,
            expectedResultType: Issue.self) { issue, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if let issue = issue {
                    completion(.success(issue))
                }
            }
        }
    }

    /// Posts a comment on an issue using the given body.
    /// 
    /// - Parameters:
    ///   - session: GitURLSession, defaults to URLSession.sharedSession()
    ///   - owner: The user or organization that owns the repository.
    ///   - repository: The name of the repository.
    ///   - number: The number of the issue.
    ///   - body: The contents of the comment.
    ///   - completion: Callback for the comment that is created.
    /// 
    /// - Returns: URLSessionDataTaskProtocol
    @discardableResult
    func commentIssue(_ session: GitURLSession = URLSession.shared,
                      owner: String,
                      repository: String,
                      number: Int,
                      body: String,
                      completion: @escaping (
                        _ response: Result<Comment, Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = IssueRouter.commentIssue(configuration, owner, repository, number, body)
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .formatted(Time.rfc3339DateFormatter)

        return router.post(
            session,
            decoder: decoder,
            expectedResultType: Comment.self) { issue, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if let issue = issue {
                    completion(.success(issue))
                }
            }
        }
    }

    /// Fetches all comments for an issue
    /// 
    /// - Parameters:
    ///   - session: GitURLSession, defaults to URLSession.sharedSession()
    ///   - owner: The user or organization that owns the repository.
    ///   - repository: The name of the repository.
    ///   - number: The number of the issue.
    ///   - page: Current page for comments pagination. `1` by default.
    ///   - perPage: Number of comments per page. `100` by default.
    ///   - completion: Callback for the outcome of the fetch.
    /// 
    /// - Returns: URLSessionDataTaskProtocol
    @discardableResult
    func issueComments(_ session: GitURLSession = URLSession.shared,
                       owner: String,
                       repository: String,
                       number: Int,
                       page: String = "1",
                       perPage: String = "100",
                       completion: @escaping (
                        _ response: Result<[Comment], Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = IssueRouter.readIssueComments(configuration, owner, repository, number, page, perPage)

        return router.load(
            session,
            dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
            expectedResultType: [Comment].self) { comments, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if let comments = comments {
                    completion(.success(comments))
                }
            }
        }
    }

    /// Edits a comment on an issue using the given body.
    /// 
    /// - Parameters:
    ///   - session: GitURLSession, defaults to URLSession.sharedSession()
    ///   - owner: The user or organization that owns the repository.
    ///   - repository: The name of the repository.
    ///   - number: The number of the comment.
    ///   - body: The contents of the comment.
    ///   - completion: Callback for the comment that is created.
    /// 
    /// - Returns: URLSessionDataTaskProtocol
    @discardableResult
    func patchIssueComment(
        _ session: GitURLSession = URLSession.shared,
        owner: String,
        repository: String,
        number: Int,
        body: String,
        completion: @escaping (
            _ response: Result<Comment, Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = IssueRouter.patchIssueComment(configuration, owner, repository, number, body)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Time.rfc3339DateFormatter)

        return router.post(
            session, decoder: decoder,
            expectedResultType: Comment.self) { issue, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if let issue = issue {
                    completion(.success(issue))
                }
            }
        }
    }
}
// swiftlint:disable:this file_length
