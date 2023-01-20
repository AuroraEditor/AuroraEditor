//
//  SourceControlAccounts.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/12.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

public struct SourceControlAccounts: Codable, Identifiable, Hashable {
    public var id: String
    public var gitProvider: String
    public var gitProviderLink: String
    public var gitProviderDescription: String
    public var gitAccountName: String
    public var gitAccountEmail: String
    public var gitAccountUsername: String
    public var gitAccountImage: String
    // If bool we use the HTTP protocol else if false we use SHH
    public var gitCloningProtocol: Bool
    public var gitSSHKey: String
    public var isTokenValid: Bool
}
