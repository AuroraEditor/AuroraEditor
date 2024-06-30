//
//  SourceControlAccounts.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/12.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// A struct to represent a source control account
public struct SourceControlAccounts: Codable, Identifiable, Hashable {
    /// The unique identifier for the account
    public var id: String

    /// The name of the provider
    public var gitProvider: String

    /// The link to the provider
    public var gitProviderLink: String

    /// The description of the provider
    public var gitProviderDescription: String

    /// The name of the account
    public var gitAccountName: String

    /// The email of the account
    public var gitAccountEmail: String

    /// The username of the account
    public var gitAccountUsername: String

    /// The image of the account
    public var gitAccountImage: String

    // If bool we use the HTTP protocol else if false we use SHH
    /// The cloning protocol
    public var gitCloningProtocol: Bool

    /// The SSH key of the account
    public var gitSSHKey: String

    /// Is the token valid
    public var isTokenValid: Bool
}
