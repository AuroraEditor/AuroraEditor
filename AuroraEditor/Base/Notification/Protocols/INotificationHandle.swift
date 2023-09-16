//
//  INotificationHandle.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

protocol INotificationHandle {

    /// Allows to update the severity of the notification.
    func updateSeverity(severity: Severity)

    /// Allows to update the message of the notification even after the
    /// notification is already visible.
    func updateMessage(message: String)

    /// Hide the notification and remove it from the notification center.
    func close()
}
