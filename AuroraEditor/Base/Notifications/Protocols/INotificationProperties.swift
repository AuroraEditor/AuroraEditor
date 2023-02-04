//
//  INotificationProperties.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 03/02/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

protocol INotificationProperties {

    /// Silent notifications are not shown to the user unless the notification center
    /// is opened. The status bar will still indicate all number of notifications to
    /// catch some attention.
    var silent: Bool? { get }

    /// Adds an action to never show the notification again. The choice will be persisted
    /// such as future requests will not cause the notification to show again.
    var neverShowAgain: INeverShowAgainOptions? { get }

}
