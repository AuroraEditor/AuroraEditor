//
//  INotificationsModel.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 03/02/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

protocol INotificationsModel {
    func addNotification(notification: INotification)
    func setFilter(filter: NotificationsFilter)
}
