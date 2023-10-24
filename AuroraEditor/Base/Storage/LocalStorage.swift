//
//  LocalStorage.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
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

    /**
     Saves a notification as "do not show again" in persistent storage.

     - Parameter notification: The INotification object to be marked as "do not show again" and saved.

     This function appends the provided `INotification` object to the list of notifications that should not be 
     displayed again. It then encodes the updated list as JSON data and stores it in persistent storage using the
     "doNotShowNotifications" key. This allows you to maintain a list of notifications that have been marked 
     for exclusion from future display.

     - Parameter notification: The INotification object representing the notification to be saved.

     - Note: The INotification type is assumed to conform to the Codable protocol. The INotification type should have
             the same structure as the data stored under the "doNotShowNotifications" key to ensure proper 
             encoding and decoding.

     - SeeAlso: `listDoNotShowNotifications()`
     - SeeAlso: `INotification`
     - Warning: Ensure that the INotification type conforms to the Codable protocol and matches the structure of the 
                data stored under the "doNotShowNotifications" key. Inconsistencies may lead to decoding errors.
     */
    public func saveDoNotShowNotification(notification: INotification) {
        var notificationList = listDoNotShowNotifications()
        notificationList.append(notification)

        do {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(notificationList) {
                storage.set(encoded, forKey: "doNotShowNotifications")
            }
        }
    }

    /**
     Retrieves a list of notifications that have been marked as "do not show again" from persistent storage.

     - Returns: An array of INotification objects representing the notifications that should not be displayed again.

     This function attempts to retrieve the list of notifications from persistent storage, which
     is assumed to be stored as JSON data. It uses the `JSONDecoder` to decode the stored
     data into an array of INotification objects. If the decoding is successful, it returns the decoded array.
     If any errors occur during decoding or if the data is not found, an empty array is returned.

     - Note: The INotification type is assumed to conform to the Codable protocol. The INotification type represents 
             the structure of the notification objects you want to store and retrieve.

     - SeeAlso: `saveDoNotShowNotification(notification:)`
     - SeeAlso: `INotification`
     - Warning: Ensure that the INotification type conforms to the Codable protocol and has the same structure as the 
                data stored in the "doNotShowNotifications" key. In case of discrepancies, decoding errors may occur.
     */
    public func listDoNotShowNotifications() -> [INotification] {
        if let data = storage.data(forKey: "doNotShowNotifications") {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([INotification].self, from: data) {
                return decoded
            }
        }
        return []
    }
}
