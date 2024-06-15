//
//  AvatarURL.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

@available(*, deprecated, renamed: "VersionControl", message: "This will be deprecated in favor of the new VersionControl Remote SDK APIs.")
/// Avatar URL
open class AvatarURL: Codable {

    /// URL
    open var url: URL?

    /// Initialize
    /// 
    /// - Parameter json: JSON
    public init(_ json: [String: AnyObject]) {
        if let urlString = json["url"] as? String, let urlFromString = URL(string: urlString) {
            url = urlFromString
        }
    }
}
