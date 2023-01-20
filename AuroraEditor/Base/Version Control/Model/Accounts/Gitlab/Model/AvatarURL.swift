//
//  AvatarURL.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

open class AvatarURL: Codable {
    open var url: URL?

    public init(_ json: [String: AnyObject]) {
        if let urlString = json["url"] as? String, let urlFromString = URL(string: urlString) {
            url = urlFromString
        }
    }
}
