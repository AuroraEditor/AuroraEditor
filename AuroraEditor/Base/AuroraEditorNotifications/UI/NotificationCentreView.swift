//
//  NotificationCentreView.swift
//  
//
//  Created by Nanashi Li on 2022/07/12.
//

import SwiftUI

public struct NotificationCentreView: View {

    @ObservedObject
    private var notificationCentre: NotificationManager = .shared

    public init() {}

    public var body: some View {
        VStack {
            Text("Notifications")
                .padding(.top)

            // Non-constant range: not an integer range
            List(notificationCentre.banners.indices) { notification in
                notificationCentre.banners[notification].data.makeBanner(
                    isPresented: $notificationCentre.banners[notification].isPresented,
                    isRemoved: $notificationCentre.banners[notification].isRemoved
                )
            }
        }
    }
}
