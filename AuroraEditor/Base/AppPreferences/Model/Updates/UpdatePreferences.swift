//
//  UpdatePreferences.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/09/23.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

public extension AppPreferences {

    struct UpdatePreferences: Codable {

        public var checkForUpdates: Bool = true

        public var downloadUpdatesWhenAvailable: Bool = true

        public var updateChannel: UpdateChannel = .release

        public var lastChecked: Date = Date()

        public init() {}

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.checkForUpdates = try container.decodeIfPresent(
                Bool.self,
                forKey: .checkForUpdates
            ) ?? true
            self.downloadUpdatesWhenAvailable = try container.decodeIfPresent(
                Bool.self,
                forKey: .downloadUpdatesWhenAvailable
            ) ?? true
            self.updateChannel = try container.decodeIfPresent(
                UpdateChannel.self,
                forKey: .updateChannel
            ) ?? .release
            self.lastChecked = try container.decodeIfPresent(
                Date.self,
                forKey: .lastChecked
            ) ?? Date()
        }
    }

    enum UpdateChannel: Codable {
        case release
        case beta
        case nightly
    }
}
