//
//  BannerModule.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/07/12.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

public struct BannerModule: Codable, Identifiable {
    public var id: String { UUID().uuidString }
    public let data: NotificationData
    public var isPresented: Bool = true
    public var isRemoved: Bool = false
}
