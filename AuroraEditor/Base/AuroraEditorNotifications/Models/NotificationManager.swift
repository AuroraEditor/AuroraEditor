//
//  NotificationManager.swift
//  
//
//  Created by Nanashi Li on 2022/07/12.
//

import Foundation

public class NotificationManager: ObservableObject {

    public static let shared: NotificationManager = .init()

    @Published
    public var banners: [BannerModule] = []

    public init() {}

    public func postProgressNotification(title: String, progress: Progress) {
        banners.append(
            BannerModule(
                data: NotificationData(title: title,
                                       priority: .info,
                                       style: .progress)))
    }

    func postActionNotification(title: String,
                                priority: NotificationData.Priority,
                                primary: @escaping (() -> Void),
                                primaryTitle: String,
                                source: String) {
        banners.append(
            BannerModule(data: NotificationData(title: title,
                                                source: source,
                                                priority: priority,
                                                style: .action,
                                                primaryTitle: primaryTitle)))
    }

    public func showInformationMessage(_ mes: String) {
        DispatchQueue.main.async {
            self.banners.append(BannerModule(data: NotificationData(title: mes,
                                                              priority: .info,
                                                              style: .basic)))
        }
    }

    public func showWarningMessage(_ mes: String) {
        DispatchQueue.main.async {
            self.banners.append(BannerModule(data: NotificationData(title: mes,
                                                              priority: .warning,
                                                              style: .basic))
            )
        }
    }

    public func showErrorMessage(_ mes: String) {
        DispatchQueue.main.async {
            self.banners.append(BannerModule(data: NotificationData(title: mes,
                                                              priority: .error,
                                                              style: .basic)))
        }
    }

}
