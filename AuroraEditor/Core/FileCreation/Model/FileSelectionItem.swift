//
//  FileSelectionItem.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/30.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

/// File selection item
struct FileSelectionItem: Codable, Hashable {
    /// Language name
    var languageName: String

    /// Language icon
    var langaugeIcon: String

    /// Language extension
    var languageExtension: String
}
