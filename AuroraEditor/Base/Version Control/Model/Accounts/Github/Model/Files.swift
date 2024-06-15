//
//  Files.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Files (`[String:File]`)
public typealias Files = [String: File]

/// File class
open class File: Codable {

    /// File Identifier
    open private(set) var id: Int = -1

    /// Raw URL
    open var rawURL: URL?

    /// Filename
    open var filename: String?

    /// File Type
    open var type: String?

    /// Language
    open var language: String?

    /// File Size
    open var size: Int?

    /// File Content
    open var content: String?

    /// Coding keys
    enum CodingKeys: String, CodingKey {
        case rawURL = "raw_url"
        case filename
        case type
        case language
        case size
        case content
    }
}
