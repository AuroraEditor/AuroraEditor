//
//  Git.swift
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
public extension GithubAccount {

    /// Deletes a reference.
    /// 
    /// - Parameters:
    ///     - session: GitURLSession, defaults to URLSession.shared()
    ///     - owner: The user or organization that owns the repositories.
    ///     - repo: The repository on which the reference needs to be deleted.
    ///     - ref: The reference to delete.
    ///     - completion: Callback for the outcome of the deletion.
    /// 
    /// - Returns: URLSessionDataTaskProtocol
    @discardableResult
    func deleteReference(_ session: GitURLSession = URLSession.shared,
                         owner: String,
                         repository: String,
                         ref: String,
                         completion: @escaping (
                            _ response: Error?) -> Void) -> URLSessionDataTaskProtocol? {

        let router = GitRouter.deleteReference(configuration, owner, repository, ref)
        return router.load(session, completion: completion)
    }
}
