//
//  NotificationsPreferences.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

public extension AppPreferences {

    /// The global settings for the notification system
    struct NotificationsPreferences: Codable {

        /// Allows notifications to be sent to the user
        public var notificationsEnabled: Bool = true

        /// if true, the notifications system ignores all notifications except errors
        public var doNotDisturb: Bool = false

        /// if true, notifications will be allowed on all profiles
        public var allProfiles: Bool = false

        /// Default initializer
        public init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.notificationsEnabled = try container.decodeIfPresent(Bool.self,
                                                                      forKey: .notificationsEnabled) ?? true
            self.doNotDisturb = try container.decodeIfPresent(Bool.self,
                                                              forKey: .doNotDisturb) ?? false
            self.allProfiles = try container.decodeIfPresent(Bool.self,
                                                             forKey: .allProfiles) ?? false
        }
    }
}
