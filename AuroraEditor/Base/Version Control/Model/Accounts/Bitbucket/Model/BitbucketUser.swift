//
//  BitbucketUser.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

/// Bitbucket user
open class BitbucketUser: Codable {

    /// Identifier
    open var id: String?

    /// Login
    open var login: String?

    /// Name
    open var name: String?

    enum CodingKeys: String, CodingKey {
        case id
        case login = "username"
        case name = "display_name"
    }
}

/// Bitbucket email
open class Email: Codable {

    /// is primary email
    open var isPrimary: Bool

    /// is confirmed email
    open var isConfirmed: Bool

    /// email type
    open var type: String?

    /// email
    open var email: String?

    enum CodingKeys: String, CodingKey {
        case isPrimary = "is_primary"
        case isConfirmed = "is_confirmed"
        case type = "type"
        case email = "email"
    }
}

public extension BitbucketAccount {

    /// Current user
    /// 
    /// - Parameters:
    ///   - session: URL session
    ///   - completion: completion
    /// 
    /// - Returns: URLSessionDataTaskProtocol
    func me(
        _ session: GitURLSession = URLSession.shared,
        completion: @escaping (_ response: Result<BitbucketUser, Error>) -> Void) -> URLSessionDataTaskProtocol? {

            let router = BitbucketUserRouter.readAuthenticatedUser(configuration)

            return router.load(session,
                               dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                               expectedResultType: BitbucketUser.self) { user, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    if let user = user {
                        completion(.success(user))
                    }
                }
            }
        }

    /// Get Emails
    /// 
    /// - Parameters:
    ///   - session: GIT Session
    ///   - completion: completion
    /// 
    /// - Returns: URLSessionDataTaskProtocol
    func emails(
        _ session: GitURLSession = URLSession.shared,
        completion: @escaping (_ response: Result<Email, Error>) -> Void) -> URLSessionDataTaskProtocol? {

            let router = BitbucketUserRouter.readEmails(configuration)

            return router.load(session,
                               dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                               expectedResultType: Email.self) { email, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    if let email = email {
                        completion(.success(email))
                    }
                }
            }
    }
}
