//
//  INotificationService .swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

protocol INotificationService {

    /// The DND mode can be enabled or disabled
    /// and will result in all info and warning
    /// notifications to be silent.
    var doNotDisturbMode: Bool { get set }

    /// Show the provided notification to the user. The returned `INotificationHandle`
    /// can be used to control the notification afterwards.
    func notify(notification: INotification)

    /// A convenient way of reporting infos. Use the `INotificationService.notify`
    /// method if you need more control over the notification.
    func info(title: String, message: String)

    /// A convenient way of reporting warnings. Use the `INotificationService.notify`
    /// method if you need more control over the notification.
    func warn(title: String, message: String)

    /// A convenient way of reporting errors. Use the `INotificationService.notify`
    /// method if you need more control over the notification.
    func error(title: String, message: String)
}
