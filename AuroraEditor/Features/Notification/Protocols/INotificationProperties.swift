//
//  INotificationProperties.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// The `INotificationProperties` protocol defines properties for configuring notification behavior.
protocol INotificationProperties {
    /// A flag indicating whether the notification should be shown silently to the user.
    ///
    /// Silent notifications are not displayed as alerts to the user, but they may still be
    /// indicated in the status bar to catch some attention.
    var silent: Bool? { get }

    /// Options to configure whether the notification should never be shown again.
    ///
    /// By adding an action to never show the notification again, the user's choice will
    /// be persisted, and future requests will not cause the notification to appear.
    var neverShowAgain: INeverShowAgainOptions? { get }
}
