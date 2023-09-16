//
//  NotificationObserver.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import AppKit

class NotificationObserver: NSObject {
    var objectToObserve: NotificationsModel

    var observation: NSKeyValueObservation?

    init(object: NotificationsModel) {
        objectToObserve = object
        super.init()

        observation = observe(
            \.objectToObserve.showNotificationToast,
             options: [.old, .new]
        ) { _, change in
            Log.debug("Show notification changed from: \(change.oldValue!), updated to: \(change.newValue!)")
        }
    }
}
