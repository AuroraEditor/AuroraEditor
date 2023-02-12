//
//  LocalStorage.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 11/02/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// The `LocalStorage` class handles saving data to the `UserDefaults` without having the need
/// to constantly type out the whole `UserDefaults` setup and read.
///
/// Usage is as follows:
///
/// ```swift
/// private var storage: LocalStorage
///
/// storage.saveDoNotShowNotifcation("121DD622-1624-4AF7-ADF7-528F81512925")
///  ```
class LocalStorage {

    private let storage = UserDefaults.standard

    /// This function registers any `UserDefault` locations that may not exist
    public func registerStorage() {
        storage.register(defaults: [
            "doNotShowNotifications": []
        ])
    }

    /// Adds a notification that was marked as do not show again
    public func saveDoNotShowNotifcation(id notificationId: String) {

        var notificationList = listDoNotShowNotification()
        notificationList.append(notificationId)

        storage.set(notificationList, forKey: "doNotShowNotifications")
    }

    /// This retrieves the list of notifications that was marked as do not show again.
    public func listDoNotShowNotification() -> [String] {
        storage.stringArray(forKey: "doNotShowNotifications") ?? []
    }
}
