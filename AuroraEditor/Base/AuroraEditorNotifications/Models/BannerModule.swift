//
//  BannerModule.swift
//  
//
//  Created by Nanashi Li on 2022/07/12.
//

import Foundation

public struct BannerModule: Codable, Identifiable {
    public var id: String { UUID().uuidString }
    public let data: NotificationData
    public var isPresented: Bool = true
    public var isRemoved: Bool = false
}
