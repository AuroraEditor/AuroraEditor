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

public struct Plugin: Codable, Hashable, Identifiable, Comparable, TabBarItemRepresentable {
    public static func < (lhs: Plugin, rhs: Plugin) -> Bool {
        lhs.id.uuidString < rhs.id.uuidString
    }

    public static func == (lhs: Plugin, rhs: Plugin) -> Bool {
        lhs.id == rhs.id
    }
    public var tabID: TabBarItemID {
        .extensionInstallation(id.uuidString)
    }

    public var title: String {
        return self.extensionName
    }

    public var icon: Image {
        Image(systemName: "puzzlepiece.extension.fill")
    }

    public var iconColor: Color {
        .blue
    }

    // Extension Info
    public var id: UUID
    var extensionDescription: String
    var extensionImage: String
    var extensionName: String
    var download: Int
    var category: String
    var tags: [String]

    // Extension Creator
    var creator: ExtensionCreator

    // Editor
    var editorSupportVersion: String

    // Developer Links
    var developerLinks: DeveloperLinks

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public struct ExtensionCreator: Codable {
    var id: UUID
    var name: String
    var username: String
    var profileImage: String
    var profileUrl: String

    enum CodingKeys: String, CodingKey {
        case id = "creator_id"
        case name = "creator_name"
        case username = "creator_username"
        case profileImage = "creator_profile_image"
        case profileUrl = "creator_profile_url"
    }
}

public struct DeveloperLinks: Codable {
    var license: String
    var issues: String
    var privacyPolicy: String
    var termsOfService: String

    enum CodingKeys: String, CodingKey {
        case license
        case issues
        case privacyPolicy = "privacy_policy"
        case termsOfService = "terms_of_service"
    }
}
