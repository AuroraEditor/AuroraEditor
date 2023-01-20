//
//  BitbucketRepositories.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

// TODO: DOCS (Nanashi Li)
open class BitbucketRepositories: Codable {
    open var id: String
    open var owner: BitbucketUser
    open var name: String?
    open var fullName: String?
    open var isPrivate: Bool
    open var repositoryDescription: String?
    open var gitURL: String?
    open var sshURL: String?
    open var cloneURL: String?
    open var size: Int
    open var scm: String?

    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case owner
        case name
        case fullName = "full_name"
        case isPrivate = "is_private"
        case repositoryDescription = "description"
        case gitURL = "git://"
        case sshURL = "ssh://"
        case cloneURL = "https://"
        case size
        case scm
    }
}

/// Paginated response
public enum PaginatedResponse<T> {
    /// Success
    case success(values: T, nextParameters: [String: String])
    /// Failure
    case failure(Error)
}

public extension BitbucketAccount {
    /// Repositories
    /// - Parameters:
    ///   - session: GIT URLSession
    ///   - userName: Username
    ///   - nextParameters: Next parameters
    ///   - completion: completion
    /// - Returns: URLSessionDataTaskProtocol
    func repositories(_ session: GitURLSession = URLSession.shared,
                      userName: String? = nil,
                      nextParameters: [String: String] = [:],
                      completion: @escaping (
                                _ response: PaginatedResponse<[BitbucketRepositories]>) -> Void) ->
    URLSessionDataTaskProtocol? {

        let router = BitbucketRepositoryRouter.readRepositories(configuration, userName, nextParameters)

        return router.load(session,
                           dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                           expectedResultType: BitbucketRepositories.self) { repo, error in

            if let error = error {
                completion(PaginatedResponse.failure(error))
            } else {
                if let repo = repo {
                    completion(PaginatedResponse.success(values: [repo], nextParameters: [:]))
                }
            }
        }
    }

    /// Repository
    /// - Parameters:
    ///   - session: GIT URLSession
    ///   - owner: Owner
    ///   - name: Name
    ///   - completion: completion
    /// - Returns: URLSessionDataTaskProtocol
    func repository(_ session: GitURLSession = URLSession.shared,
                    owner: String,
                    name: String,
                    completion: @escaping (
                        _ response: Result<BitbucketRepositories, Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = BitbucketRepositoryRouter.readRepository(configuration, owner, name)

        return router.load(session,
                           dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                           expectedResultType: BitbucketRepositories.self) { data, error in

            if let error = error {
                completion(Result.failure(error))
            }

            if let data = data {
                completion(Result.success(data))
            }
        }
    }
}
