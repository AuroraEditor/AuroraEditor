//
//  UpdatePreferences.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/23.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

public extension AppPreferences {
    /// The preferences for updates
    struct UpdatePreferences: Codable {
        /// Check for updates
        public var checkForUpdates: Bool = true

        /// Download updates when available
        public var downloadUpdatesWhenAvailable: Bool = true

        /// The update channel
        public var updateChannel: UpdateChannel = .release

        /// The last time the app checked for updates
        public var lastChecked: Date = Date()

        /// Initializes the update preferences
        public init() {}

        /// Initializes the update preferences
        /// 
        /// - Parameter decoder: The decoder
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

    /// The update channel
    enum UpdateChannel: String, Codable {
        /// The release channel
        case release

        /// The beta channel
        case beta

        /// The nightly channel
        case nightly
    }
}
