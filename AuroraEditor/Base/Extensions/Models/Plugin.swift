//
//  Plugin.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 5.04.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI
import AEExtensionKit

/// Plugin
public struct Plugin: Codable, Hashable, Identifiable, Comparable, TabBarItemRepresentable {
    /// Is less than
    /// 
    /// - Parameter lhs: left hand side
    /// - Parameter rhs: right hand side
    /// 
    /// - Returns: true if less than
    public static func < (lhs: Plugin, rhs: Plugin) -> Bool {
        lhs.id.uuidString < rhs.id.uuidString
    }

    /// Equate
    /// 
    /// - Parameter lhs: left hand side
    /// - Parameter rhs: right hand side
    /// 
    /// - Returns: true if equal
    public static func == (lhs: Plugin, rhs: Plugin) -> Bool {
        lhs.id == rhs.id
    }

    /// Unique identifier of the plugin.
    public var tabID: TabBarItemID {
        .extensionInstallation(id.uuidString)
    }

    /// Unique identifier of the plugin.
    public var title: String {
        return self.extensionName
    }

    /// Unique identifier of the plugin.
    public var icon: Image {
        Image(systemName: "puzzlepiece.extension.fill")
    }

    /// Unique identifier of the plugin.
    public var iconColor: Color {
        .blue
    }

    // Extension Info
    /// Unique identifier of the plugin.
    public var id: UUID

    /// Extension Description
    var extensionDescription: String

    /// Extension Image
    var extensionImage: String

    /// Extension Name
    var extensionName: String

    /// Extension Version
    var download: Int

    /// Extension Version
    var category: String

    /// Extension tags
    var tags: [String]

    /// Extension Creator
    var creator: ExtensionCreator

    /// Editor
    var editorSupportVersion: String

    /// Developer Links
    var developerLinks: DeveloperLinks

    /// Hash
    /// 
    /// - Parameter hasher: hasher
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// Extension Creator
public struct ExtensionCreator: Codable {
    /// Unique identifier of the creator.
    var id: UUID

    /// Creator Name
    var name: String

    /// Creator Username
    var username: String

    /// Creator Profile Image
    var profileImage: String

    /// Creator Profile URL
    var profileUrl: String

    enum CodingKeys: String, CodingKey {
        case id = "creator_id"
        case name = "creator_name"
        case username = "creator_username"
        case profileImage = "creator_profile_image"
        case profileUrl = "creator_profile_url"
    }
}

/// Developer Links
public struct DeveloperLinks: Codable {
    /// License
    var license: String

    /// Issues
    var issues: String

    /// Privacy Policy
    var privacyPolicy: String

    /// Terms of Service
    var termsOfService: String

    enum CodingKeys: String, CodingKey {
        case license
        case issues
        case privacyPolicy = "privacy_policy"
        case termsOfService = "terms_of_service"
    }
}
