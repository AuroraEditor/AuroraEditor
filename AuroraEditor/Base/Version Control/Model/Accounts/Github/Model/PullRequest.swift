//
//  PullRequest.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Pull Request
open class PullRequest: Codable {

    /// Pull Request Identifier
    open private(set) var id: Int = -1

    /// Pull Request URL
    open var url: URL?

    /// Pull Request HTML URL
    open var htmlURL: URL?

    /// Pull Request Diff URL
    open var diffURL: URL?

    /// Pull Request Patch URL
    open var patchURL: URL?

    /// Pull Request Issue URL
    open var issueURL: URL?

    /// Pull Request Commits URL
    open var commitsURL: URL?

    /// Pull Request Review Comments URL
    open var reviewCommentsURL: URL?

    /// Pull Request Comments URL
    open var reviewCommentURL: URL?

    /// Pull Request Comments URL
    open var commentsURL: URL?

    /// Pull Request Statuses URL
    open var statusesURL: URL?

    /// Pull Request Title
    open var title: String?

    /// Pull Request Body
    open var body: String?

    /// Pull Request Assignee
    open var assignee: GithubUser?

    /// Pull Request Locked
    open var locked: Bool?

    /// Pull Request Created At
    open var createdAt: Date?

    /// Pull Request Updated At
    open var updatedAt: Date?

    /// Pull Request Closed At
    open var closedAt: Date?

    /// Pull Request Merged At
    open var mergedAt: Date?

    /// Pull Request User
    open var user: GithubUser?

    /// Pull Request Number
    open var number: Int

    /// Pull Request State
    open var state: Openness?

    /// Pull Request Head
    open var head: PullRequest.Branch?

    /// Pull Request Base
    open var base: PullRequest.Branch?

    /// Pull Request Requested Reviewers
    open var requestedReviewers: [GithubUser]?

    /// Pull Request Draft
    open var draft: Bool?

    /// Coding keys
    enum CodingKeys: String, CodingKey {
        case id
        case url
        case diffURL = "diff_url"
        case patchURL = "patch_url"
        case issueURL = "issue_url"
        case commitsURL = "commits_url"
        case reviewCommentsURL = "review_comments_url"
        case commentsURL = "comments_url"
        case statusesURL = "statuses_url"
        case htmlURL = "html_url"
        case number
        case state
        case title
        case body
        case assignee
        case locked
        case user
        case closedAt = "closed_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case mergedAt = "merged_at"
        case head
        case base
        case requestedReviewers = "requested_reviewers"
        case draft
    }

    open class Branch: Codable {
        open var label: String?
        open var ref: String?
        open var sha: String?
        open var user: GithubUser?
        open var repo: GithubRepositories?
    }
}

public extension GithubAccount {

    /// Get a single pull request
    /// 
    /// - parameter session: GitURLSession, defaults to URLSession.shared
    /// - parameter owner: The user or organization that owns the repositories.
    /// - parameter repository: The name of the repository.
    /// - parameter number: The number of the PR to fetch.
    /// - parameter completion: Callback for the outcome of the fetch.
    ///
    /// - Returns: URLSessionDataTaskProtocol
    @discardableResult
    func pullRequest(_ session: GitURLSession = URLSession.shared,
                     owner: String,
                     repository: String,
                     number: Int,
                     completion: @escaping (
                        _ response: Result<PullRequest, Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = PullRequestRouter.readPullRequest(configuration, owner, repository, "\(number)")

        return router.load(
            session,
            dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
            expectedResultType: PullRequest.self) { pullRequest, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if let pullRequest = pullRequest {
                    completion(.success(pullRequest))
                }
            }
        }
    }

    /// Get a list of pull requests
    /// 
    /// - parameter session: GitURLSession, defaults to URLSession.shared
    /// - parameter owner: The user or organization that owns the repositories.
    /// - parameter repository: The name of the repository.
    /// - parameter base: Filter pulls by base branch name.
    /// - parameter head: Filter pulls by user or organization and branch name.
    /// - parameter state: Filter pulls by their state.
    /// - parameter direction: The direction of the sort.
    /// - parameter completion: Callback for the outcome of the fetch.
    ///
    /// - Returns: URLSessionDataTaskProtocol
    @discardableResult
    func pullRequests(_ session: GitURLSession = URLSession.shared,
                      owner: String,
                      repository: String,
                      base: String? = nil,
                      head: String? = nil,
                      state: Openness = .open,
                      sort: SortType = .created,
                      direction: SortDirection = .desc,
                      completion: @escaping (
                        _ response: Result<[PullRequest], Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = PullRequestRouter.readPullRequests(
            configuration,
            owner,
            repository,
            base,
            head,
            state,
            sort,
            direction)

        return router.load(
            session,
            dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
            expectedResultType: [PullRequest].self) { pullRequests, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if let pullRequests = pullRequests {
                    completion(.success(pullRequests))
                }
            }
        }
    }
}
