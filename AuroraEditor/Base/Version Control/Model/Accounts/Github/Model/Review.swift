//
//  Review.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Review
public struct Review {
    /// Body
    public let body: String
    /// Commit ID
    public let commitID: String
    /// ID
    public let id: Int
    /// State
    public let state: State
    /// Date
    public let submittedAt: Date
    /// User
    public let user: GithubUser
}

extension Review: Codable {
    enum CodingKeys: String, CodingKey {
        case body
        case commitID = "commit_id"
        case id
        case state
        case submittedAt = "submitted_at"
        case user
    }
}

public extension Review {
    enum State: String, Codable, Equatable {
        case approved = "APPROVED"
        case changesRequested = "CHANGES_REQUESTED"
        case comment = "COMMENTED"
        case dismissed = "DISMISSED"
        case pending = "PENDING"
    }
}

public extension GithubAccount {
    /// List reviews
    /// - Parameters:
    ///   - session: GIT URLSession
    ///   - owner: Owner
    ///   - repository: Repository
    ///   - pullRequestNumber: Pullrequest number
    ///   - completion: Completion
    /// - Returns: URLSessionDataTaskProtocol
    @discardableResult
    func listReviews(_ session: GitURLSession = URLSession.shared,
                     owner: String,
                     repository: String,
                     pullRequestNumber: Int,
                     completion: @escaping (
                        _ response: Result<[Review], Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = ReviewsRouter.listReviews(configuration, owner, repository, pullRequestNumber)

        return router.load(
            session,
            dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
            expectedResultType: [Review].self) { pullRequests, error in

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
