//
//  NotificationObserver.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import AppKit

/// The `NotificationObserver` class observes changes in the `showNotificationToast`
/// property of a `NotificationsModel` instance.
class NotificationObserver: NSObject {
    /// The `NotificationsModel` instance to observe for changes.
    var objectToObserve: NotificationsModel

    /// An observation token to keep track of the observation.
    var observation: NSKeyValueObservation?

    /// Initializes a new `NotificationObserver` instance.
    ///
    /// - Parameter object: The `NotificationsModel` instance to observe for changes.
    init(object: NotificationsModel) {
        objectToObserve = object
        super.init()

        // Observe changes in the `showNotificationToast` property.
        observation = observe(
            \.objectToObserve.showNotificationToast,
             options: [.old, .new]
        ) { _, change in
            Log.debug("Show notification changed from: \(change.oldValue!), updated to: \(change.newValue!)")
        }
    }
}
